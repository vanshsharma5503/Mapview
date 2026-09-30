import CoreGraphics
import UIKit

final class ColoringEngine: @unchecked Sendable {
    let width: Int
    let height: Int
    let regions: [ColoringRegion]

    private let source: ColoringPixelBuffer
    private let boundaryMap: [Bool]
    private let regionMap: [Int]
    private let configuration: ColoringBoundaryConfiguration
    private var colorLayer: [UInt32]
    private var undoStack: [ColoringAction] = []
    private var redoStack: [ColoringAction] = []
    private var pendingStrokeChanges: [Int: ColoringPixelChange] = [:]
    private var activeStrokeRegionID: Int?

    convenience init(
        image: UIImage,
        configuration: ColoringBoundaryConfiguration = .init()
    ) throws {
        try self.init(pixelBuffer: ColoringPixelBuffer(image: image), configuration: configuration)
    }

    nonisolated init(
        pixelBuffer: ColoringPixelBuffer,
        configuration: ColoringBoundaryConfiguration = .init()
    ) throws {
        guard pixelBuffer.width > 0, pixelBuffer.height > 0,
              pixelBuffer.bytes.count == pixelBuffer.width * pixelBuffer.height * 4 else {
            throw ColoringEngineError.invalidImage
        }
        source = pixelBuffer
        width = pixelBuffer.width
        height = pixelBuffer.height
        self.configuration = configuration
        let analysis = RegionDetector.analyze(pixels: pixelBuffer, configuration: configuration)
        boundaryMap = analysis.boundaryMap
        regionMap = analysis.regionMap
        regions = analysis.regions
        colorLayer = Array(repeating: 0, count: width * height)
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    var meaningfulRegionCount: Int { regions.count(where: \.isMeaningful) }

    func isBoundary(x: Int, y: Int) -> Bool {
        guard let index = index(x: x, y: y) else { return true }
        return boundaryMap[index]
    }

    @discardableResult
    func fill(at point: CGPoint, color: UInt32) -> Bool {
        guard let index = index(point), let regionID = meaningfulRegionID(at: index) else { return false }
        let changes = FloodFillEngine.changes(
            regionID: regionID,
            regionMap: regionMap,
            colorLayer: colorLayer,
            newColor: color
        )
        for change in changes { colorLayer[change.index] = change.newColor }
        return commit(changes)
    }

    @discardableResult
    func beginStroke(at point: CGPoint) -> Bool {
        pendingStrokeChanges.removeAll(keepingCapacity: true)
        guard let centerIndex = index(point), let regionID = meaningfulRegionID(at: centerIndex) else {
            activeStrokeRegionID = nil
            return false
        }
        activeStrokeRegionID = regionID
        return true
    }

    @discardableResult
    func applyBrush(at point: CGPoint, radius: Int, color: UInt32) -> Bool {
        guard let centerIndex = index(point), let regionID = activeStrokeRegionID else { return false }
        let centerX = centerIndex % width
        let centerY = centerIndex / width
        var changed = false

        for y in max(0, centerY - radius)...min(height - 1, centerY + radius) {
            for x in max(0, centerX - radius)...min(width - 1, centerX + radius) {
                let dx = x - centerX
                let dy = y - centerY
                guard dx * dx + dy * dy <= radius * radius else { continue }
                let pixelIndex = y * width + x
                guard regionMap[pixelIndex] == regionID, !boundaryMap[pixelIndex], colorLayer[pixelIndex] != color else { continue }
                let previous = pendingStrokeChanges[pixelIndex]?.previousColor ?? colorLayer[pixelIndex]
                pendingStrokeChanges[pixelIndex] = ColoringPixelChange(index: pixelIndex, previousColor: previous, newColor: color)
                colorLayer[pixelIndex] = color
                changed = true
            }
        }
        return changed
    }

    @discardableResult
    func endStroke() -> Bool {
        let action = ColoringAction(changes: pendingStrokeChanges.values.sorted { $0.index < $1.index })
        pendingStrokeChanges.removeAll(keepingCapacity: true)
        activeStrokeRegionID = nil
        guard !action.changes.isEmpty else { return false }
        undoStack.append(action)
        redoStack.removeAll()
        return true
    }

    func undo() {
        guard let action = undoStack.popLast() else { return }
        for change in action.changes { colorLayer[change.index] = change.previousColor }
        redoStack.append(action)
    }

    func redo() {
        guard let action = redoStack.popLast() else { return }
        for change in action.changes { colorLayer[change.index] = change.newColor }
        undoStack.append(action)
    }

    func reset() {
        colorLayer = Array(repeating: 0, count: colorLayer.count)
        undoStack.removeAll()
        redoStack.removeAll()
        pendingStrokeChanges.removeAll()
        activeStrokeRegionID = nil
    }

    func renderedImage() -> UIImage? {
        ColoringRenderer.render(source: source, boundaryMap: boundaryMap, colorLayer: colorLayer)
    }

    func progress() -> ColoringProgress {
        let meaningful = regions.filter(\.isMeaningful)
        let colored = meaningful.count { region in
            var coloredPixels = 0
            for index in regionMap.indices where regionMap[index] == region.id && colorLayer[index] != 0 {
                coloredPixels += 1
            }
            return Double(coloredPixels) / Double(region.pixelCount) >= configuration.completionCoverage
        }
        return ColoringProgress(coloredRegions: colored, totalRegions: meaningful.count)
    }

    func color(atX x: Int, y: Int) -> UInt32? {
        guard let index = index(x: x, y: y) else { return nil }
        return colorLayer[index]
    }

    private func meaningfulRegionID(at index: Int) -> Int? {
        let id = regionMap[index]
        guard id >= 0, regions[id].isMeaningful else { return nil }
        return id
    }

    private func index(_ point: CGPoint) -> Int? {
        index(x: Int(point.x.rounded(.down)), y: Int(point.y.rounded(.down)))
    }

    private func index(x: Int, y: Int) -> Int? {
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        return y * width + x
    }

    @discardableResult
    private func commit(_ changes: [ColoringPixelChange]) -> Bool {
        guard !changes.isEmpty else { return false }
        undoStack.append(ColoringAction(changes: changes))
        redoStack.removeAll()
        return true
    }
}

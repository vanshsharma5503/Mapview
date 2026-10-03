import Observation
import SwiftUI
import UIKit

struct ColoringPaletteColor: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color
    let packedRGBA: UInt32

    static let colors: [ColoringPaletteColor] = [
        .init(id: "red", name: "Red", color: .red, packedRGBA: 0xE94B4BFF),
        .init(id: "orange", name: "Orange", color: .orange, packedRGBA: 0xF28C28FF),
        .init(id: "yellow", name: "Yellow", color: .yellow, packedRGBA: 0xF4D447FF),
        .init(id: "green", name: "Green", color: .green, packedRGBA: 0x55A868FF),
        .init(id: "blue", name: "Blue", color: .blue, packedRGBA: 0x4385D1FF),
        .init(id: "purple", name: "Purple", color: .purple, packedRGBA: 0x8557B8FF),
        .init(id: "pink", name: "Pink", color: .pink, packedRGBA: 0xEE79A7FF),
        .init(id: "brown", name: "Brown", color: .brown, packedRGBA: 0x8B5A3CFF),
        .init(id: "black", name: "Black", color: .black, packedRGBA: 0x242424FF),
        .init(id: "white", name: "White", color: .white, packedRGBA: 0xFFFFFFFF)
    ]
}

@MainActor
@Observable
final class ColoringViewModel {
    private(set) var renderedImage: UIImage?
    private(set) var progress = ColoringProgress(coloredRegions: 0, totalRegions: 0)
    private(set) var errorMessage: String?
    private(set) var isLoaded = false
    private(set) var completionSequence = 0

    var selectedTool: ColoringTool = .fill
    var selectedBrushSize: ColoringBrushSize = .medium
    var selectedColor = ColoringPaletteColor.colors[0]

    let imageName: String
    private let imageLoader: ColoringImageLoading
    private let onColoringCompleted: () -> Void
    private var engine: ColoringEngine?
    private var lastBrushPoint: CGPoint?
    private var didReportCompletion = false
    private var isPreparing = false
    private var lastInteractiveRenderTime: TimeInterval = 0
    private let minimumInteractiveRenderInterval: TimeInterval = 1.0 / 24.0

    init(
        imageName: String,
        imageLoader: ColoringImageLoading? = nil,
        onColoringCompleted: @escaping () -> Void = {}
    ) {
        self.imageName = imageName
        self.imageLoader = imageLoader ?? ColoringImageLoader()
        self.onColoringCompleted = onColoringCompleted
    }

    var canUndo: Bool { engine?.canUndo == true }
    var canRedo: Bool { engine?.canRedo == true }
    var imagePixelSize: CGSize {
        guard let engine else { return .zero }
        return CGSize(width: engine.width, height: engine.height)
    }

    func loadIfNeeded() {
        guard !isLoaded, !isPreparing, errorMessage == nil else { return }
        guard let image = imageLoader.image(named: imageName) else {
            errorMessage = ColoringEngineError.imageNotFound(imageName).localizedDescription
            return
        }

        isPreparing = true
        do {
            let pixelBuffer = try ColoringPixelBuffer(image: image)
            Task {
                do {
                    let preparedEngine = try await Task.detached(priority: .userInitiated) {
                        try ColoringEngine(pixelBuffer: pixelBuffer)
                    }.value
                    engine = preparedEngine
                    isLoaded = true
                    isPreparing = false
                    refresh()
                } catch {
                    isPreparing = false
                    errorMessage = error.localizedDescription
                }
            }
        } catch {
            isPreparing = false
            errorMessage = error.localizedDescription
        }
    }

    func fill(at imagePoint: CGPoint) {
        guard selectedTool == .fill,
              engine?.fill(at: imagePoint, color: selectedColor.packedRGBA) == true else { return }
        refresh()
    }

    func beginStroke(at imagePoint: CGPoint) {
        guard selectedTool == .brush || selectedTool == .eraser, let engine else { return }
        guard engine.beginStroke(at: imagePoint) else { return }
        lastBrushPoint = imagePoint
        applyStrokePoint(imagePoint)
        refreshImageOnly()
    }

    func continueStroke(at imagePoint: CGPoint) {
        guard selectedTool == .brush || selectedTool == .eraser, let previous = lastBrushPoint else { return }
        let dx = imagePoint.x - previous.x
        let dy = imagePoint.y - previous.y
        let distance = hypot(dx, dy)
        let step = CGFloat(max(2, selectedBrushSize.pixelRadius / 2))
        let count = max(1, Int(ceil(distance / step)))
        for index in 1...count {
            let fraction = CGFloat(index) / CGFloat(count)
            applyStrokePoint(CGPoint(x: previous.x + dx * fraction, y: previous.y + dy * fraction))
        }
        lastBrushPoint = imagePoint
        refreshImageIfNeeded()
    }

    func endStroke() {
        guard engine?.endStroke() == true else {
            lastBrushPoint = nil
            return
        }
        lastBrushPoint = nil
        refresh()
    }

    func undo() {
        engine?.undo()
        didReportCompletion = false
        refresh()
    }

    func redo() {
        engine?.redo()
        refresh()
    }

    func reset() {
        engine?.reset()
        selectedTool = .fill
        selectedBrushSize = .medium
        selectedColor = ColoringPaletteColor.colors[0]
        didReportCompletion = false
        refresh()
    }

    private func applyStrokePoint(_ point: CGPoint) {
        let color = selectedTool == .eraser ? UInt32.zero : selectedColor.packedRGBA
        _ = engine?.applyBrush(at: point, radius: selectedBrushSize.pixelRadius, color: color)
    }

    private func refreshImageOnly() {
        renderedImage = engine?.renderedImage()
        lastInteractiveRenderTime = Date.timeIntervalSinceReferenceDate
    }

    private func refreshImageIfNeeded() {
        let now = Date.timeIntervalSinceReferenceDate
        guard now - lastInteractiveRenderTime >= minimumInteractiveRenderInterval else { return }
        refreshImageOnly()
    }

    private func refresh() {
        renderedImage = engine?.renderedImage()
        progress = engine?.progress() ?? ColoringProgress(coloredRegions: 0, totalRegions: 0)
        guard progress.isComplete, !didReportCompletion else { return }
        didReportCompletion = true
        completionSequence += 1
        onColoringCompleted()
    }
}

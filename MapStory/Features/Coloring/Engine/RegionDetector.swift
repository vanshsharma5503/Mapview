import Foundation

struct ColoringRegionAnalysis: Equatable, Sendable {
    let boundaryMap: [Bool]
    let regionMap: [Int]
    let regions: [ColoringRegion]
}

enum RegionDetector {
    nonisolated static func analyze(
        pixels: ColoringPixelBuffer,
        configuration: ColoringBoundaryConfiguration
    ) -> ColoringRegionAnalysis {
        let count = pixels.width * pixels.height
        var boundaries = (0..<count).map { index in
            isBoundary(pixels.rgba(at: index), configuration: configuration)
        }

        // A one-pixel safety dilation absorbs anti-aliased fringe pixels and
        // closes tiny sampling gaps without requiring pure-black source lines.
        let originalBoundaries = boundaries
        for index in 0..<count where originalBoundaries[index] {
            let x = index % pixels.width
            let y = index / pixels.width
            for offsetY in -1...1 {
                for offsetX in -1...1 {
                    let neighborX = x + offsetX
                    let neighborY = y + offsetY
                    guard neighborX >= 0, neighborX < pixels.width,
                          neighborY >= 0, neighborY < pixels.height else { continue }
                    boundaries[neighborY * pixels.width + neighborX] = true
                }
            }
        }

        var regionMap = Array(repeating: -1, count: count)
        for index in 0..<count where boundaries[index] { regionMap[index] = -2 }

        var regions: [ColoringRegion] = []
        for seed in 0..<count where regionMap[seed] == -1 {
            let id = regions.count
            var queue = [seed]
            var head = 0
            var touchesEdge = false
            regionMap[seed] = id

            while head < queue.count {
                let index = queue[head]
                head += 1
                let x = index % pixels.width
                let y = index / pixels.width
                touchesEdge = touchesEdge || x == 0 || y == 0 || x == pixels.width - 1 || y == pixels.height - 1

                let neighbors = [index - 1, index + 1, index - pixels.width, index + pixels.width]
                for neighbor in neighbors {
                    guard neighbor >= 0, neighbor < count else { continue }
                    let neighborX = neighbor % pixels.width
                    if abs(neighborX - x) > 1 || regionMap[neighbor] != -1 { continue }
                    regionMap[neighbor] = id
                    queue.append(neighbor)
                }
            }

            regions.append(ColoringRegion(id: id, pixelCount: queue.count, touchesImageEdge: touchesEdge))
        }

        let filteredRegions = regions.map { region in
            ColoringRegion(
                id: region.id,
                pixelCount: region.pixelCount,
                touchesImageEdge: region.touchesImageEdge || region.pixelCount < configuration.minimumRegionPixelCount
            )
        }
        return ColoringRegionAnalysis(boundaryMap: boundaries, regionMap: regionMap, regions: filteredRegions)
    }

    nonisolated static func isBoundary(
        _ pixel: (red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8),
        configuration: ColoringBoundaryConfiguration
    ) -> Bool {
        let alpha = Double(pixel.alpha) / 255
        guard alpha >= configuration.minimumAlpha else { return false }
        let red = Double(pixel.red) / 255
        let green = Double(pixel.green) / 255
        let blue = Double(pixel.blue) / 255
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance <= configuration.maximumLuminance
    }
}

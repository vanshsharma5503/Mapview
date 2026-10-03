import CoreGraphics
import Foundation

enum ColoringTool: String, CaseIterable, Identifiable, Sendable {
    case brush
    case fill
    case eraser

    var id: Self { self }

    var title: String { rawValue.capitalized }

    var symbolName: String {
        switch self {
        case .brush: "paintbrush.fill"
        case .fill: "paintbucket"
        case .eraser: "eraser.fill"
        }
    }
}

enum ColoringBrushSize: String, CaseIterable, Identifiable, Sendable {
    case small
    case medium
    case large

    var id: Self { self }

    var pixelRadius: Int {
        switch self {
        case .small: 8
        case .medium: 18
        case .large: 32
        }
    }
}

struct ColoringBoundaryConfiguration: Equatable, Sendable {
    var maximumLuminance: Double
    var minimumAlpha: Double
    var minimumRegionPixelCount: Int
    var completionCoverage: Double

    nonisolated init(
        maximumLuminance: Double = 0.42,
        minimumAlpha: Double = 0.18,
        minimumRegionPixelCount: Int = 80,
        completionCoverage: Double = 0.18
    ) {
        self.maximumLuminance = maximumLuminance
        self.minimumAlpha = minimumAlpha
        self.minimumRegionPixelCount = minimumRegionPixelCount
        self.completionCoverage = completionCoverage
    }
}

struct ColoringRegion: Identifiable, Equatable, Sendable {
    let id: Int
    let pixelCount: Int
    let touchesImageEdge: Bool
    var isMeaningful: Bool { !touchesImageEdge }
}

struct ColoringPixelChange: Equatable, Sendable {
    let index: Int
    let previousColor: UInt32
    let newColor: UInt32
}

struct ColoringAction: Equatable, Sendable {
    let changes: [ColoringPixelChange]
}

struct ColoringProgress: Equatable, Sendable {
    let coloredRegions: Int
    let totalRegions: Int

    var fraction: Double {
        guard totalRegions > 0 else { return 0 }
        return Double(coloredRegions) / Double(totalRegions)
    }

    var percentage: Int { Int((fraction * 100).rounded()) }
    var isComplete: Bool { totalRegions > 0 && coloredRegions == totalRegions }
}

enum ColoringEngineError: LocalizedError {
    case imageNotFound(String)
    case invalidImage
    case unableToCreateBitmap

    var errorDescription: String? {
        switch self {
        case .imageNotFound(let name): "Coloring artwork “\(name)” is not available yet."
        case .invalidImage: "The coloring artwork could not be read."
        case .unableToCreateBitmap: "The coloring canvas could not be prepared."
        }
    }
}

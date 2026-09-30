import CoreGraphics
import Testing
import UIKit
@testable import MapStory

@MainActor
struct ColoringEngineTests {
    private let red: UInt32 = 0xE94B4BFF
    private let blue: UInt32 = 0x4385D1FF

    @Test func testColoringImageLoads() {
        #expect(ColoringImageLoader().image(named: "tiger_coloring") != nil)
    }

    @Test func testBoundaryDetection() throws {
        let engine = try makeEngine()
        #expect(engine.isBoundary(x: 6, y: 3))
        #expect(!engine.isBoundary(x: 3, y: 3))
    }

    @Test func testFloodFillColorsOnlyTargetRegion() throws {
        let engine = try makeEngine()
        #expect(engine.fill(at: CGPoint(x: 3, y: 3), color: red))
        #expect(engine.color(atX: 3, y: 3) == red)
        #expect(engine.color(atX: 9, y: 3) == 0)
    }

    @Test func testFloodFillDoesNotCrossBoundary() throws {
        let engine = try makeEngine()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        #expect(engine.color(atX: 9, y: 3) == 0)
        #expect(engine.color(atX: 6, y: 3) == 0)
    }

    @Test func testFloodFillHandlesAntiAliasedBoundary() throws {
        let engine = try makeEngine(dividerValue: 95)
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: blue)
        #expect(engine.isBoundary(x: 6, y: 3))
        #expect(engine.color(atX: 9, y: 3) == 0)
    }

    @Test func testBrushStaysInsideRegion() throws {
        let engine = try makeEngine()
        #expect(engine.beginStroke(at: CGPoint(x: 4, y: 3)))
        _ = engine.applyBrush(at: CGPoint(x: 4, y: 3), radius: 8, color: red)
        _ = engine.endStroke()
        #expect(engine.color(atX: 3, y: 3) == red)
        #expect(engine.color(atX: 9, y: 3) == 0)
    }

    @Test func testBrushStrokeRemainsLockedToStartingRegion() throws {
        let engine = try makeEngine()
        #expect(engine.beginStroke(at: CGPoint(x: 3, y: 3)))
        _ = engine.applyBrush(at: CGPoint(x: 3, y: 3), radius: 2, color: red)
        _ = engine.applyBrush(at: CGPoint(x: 9, y: 3), radius: 2, color: red)
        _ = engine.endStroke()
        #expect(engine.color(atX: 3, y: 3) == red)
        #expect(engine.color(atX: 9, y: 3) == 0)
    }

    @Test func testEraserDoesNotRemoveLineArt() throws {
        let engine = try makeEngine()
        #expect(engine.beginStroke(at: CGPoint(x: 3, y: 3)))
        _ = engine.applyBrush(at: CGPoint(x: 3, y: 3), radius: 3, color: red)
        _ = engine.endStroke()
        #expect(engine.beginStroke(at: CGPoint(x: 3, y: 3)))
        _ = engine.applyBrush(at: CGPoint(x: 3, y: 3), radius: 3, color: 0)
        _ = engine.endStroke()
        #expect(engine.color(atX: 3, y: 3) == 0)
        #expect(engine.isBoundary(x: 6, y: 3))
    }

    @Test func testUndoRestoresPreviousState() throws {
        let engine = try makeEngine()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        engine.undo()
        #expect(engine.color(atX: 3, y: 3) == 0)
    }

    @Test func testRedoRestoresUndoneAction() throws {
        let engine = try makeEngine()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        engine.undo()
        engine.redo()
        #expect(engine.color(atX: 3, y: 3) == red)
    }

    @Test func testResetClearsColoring() throws {
        let engine = try makeEngine()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        engine.reset()
        #expect(engine.color(atX: 3, y: 3) == 0)
        #expect(!engine.canUndo)
        #expect(!engine.canRedo)
    }

    @Test func testProgressCalculation() throws {
        let engine = try makeEngine()
        let initial = engine.progress()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        let updated = engine.progress()
        #expect(initial.coloredRegions == 0)
        #expect(updated.coloredRegions == 1)
        #expect(updated.totalRegions == 2)
    }

    @Test func testCompletionDetection() throws {
        let engine = try makeEngine()
        _ = engine.fill(at: CGPoint(x: 3, y: 3), color: red)
        _ = engine.fill(at: CGPoint(x: 9, y: 3), color: blue)
        #expect(engine.progress().isComplete)
    }

    @Test func testDifferentStatesResolveDifferentColoringImages() {
        let punjab = makeState(id: "punjab", coloringImageName: "tiger_coloring")
        let maharashtra = makeState(id: "maharashtra", coloringImageName: "maharashtra_coloring")
        #expect(punjab.coloringImageName != maharashtra.coloringImageName)
    }

    private func makeEngine(dividerValue: UInt8 = 0) throws -> ColoringEngine {
        let width = 13
        let height = 9
        var bytes = Array(repeating: UInt8(255), count: width * height * 4)

        func setPixel(x: Int, y: Int, value: UInt8) {
            let offset = (y * width + x) * 4
            bytes[offset] = value
            bytes[offset + 1] = value
            bytes[offset + 2] = value
            bytes[offset + 3] = 255
        }

        for x in 1...11 { setPixel(x: x, y: 1, value: 0); setPixel(x: x, y: 7, value: 0) }
        for y in 1...7 { setPixel(x: 1, y: y, value: 0); setPixel(x: 11, y: y, value: 0); setPixel(x: 6, y: y, value: dividerValue) }

        let configuration = ColoringBoundaryConfiguration(
            maximumLuminance: 0.5,
            minimumAlpha: 0.1,
            minimumRegionPixelCount: 1,
            completionCoverage: 0.15
        )
        return try ColoringEngine(
            pixelBuffer: ColoringPixelBuffer(width: width, height: height, bytes: bytes),
            configuration: configuration
        )
    }

    private func makeState(id: String, coloringImageName: String) -> IndianState {
        IndianState(
            id: id,
            name: id.capitalized,
            imageName: "pb",
            puzzleImageName: "pb",
            coloringImageName: coloringImageName,
            tagline: "Tagline",
            flora: Flora(stateFlower: "Flower", stateTree: "Tree", majorCrops: []),
            fauna: Fauna(stateAnimal: "Animal", stateBird: "Bird")
        )
    }
}

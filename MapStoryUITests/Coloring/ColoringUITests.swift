import XCTest

final class ColoringUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testColoringPageLoads() {
        openPunjabColoring()
        XCTAssertTrue(app.staticTexts["Color Punjab"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Colored'")).firstMatch.exists)
    }

    func testColorPaletteSelection() {
        openPunjabColoring()
        let blue = app.buttons["color_blue"]
        XCTAssertTrue(blue.waitForExistence(timeout: 15))
        blue.tap()
        XCTAssertTrue(blue.isSelected)
    }

    func testFillToolSelection() {
        openPunjabColoring()
        let fill = app.buttons["coloring_tool_fill"]
        XCTAssertTrue(fill.waitForExistence(timeout: 15))
        fill.tap()
        XCTAssertTrue(fill.isSelected)
    }

    func testBrushToolSelection() {
        openPunjabColoring()
        let brush = app.buttons["coloring_tool_brush"]
        XCTAssertTrue(brush.waitForExistence(timeout: 15))
        brush.tap()
        XCTAssertTrue(brush.isSelected)
    }

    func testUndoButton() {
        openPunjabColoring()
        XCTAssertTrue(app.buttons["coloring_undo"].waitForExistence(timeout: 15))
    }

    func testRedoButton() {
        openPunjabColoring()
        XCTAssertTrue(app.buttons["coloring_redo"].waitForExistence(timeout: 15))
    }

    func testResetButton() {
        openPunjabColoring()
        let reset = app.buttons["coloring_reset"]
        XCTAssertTrue(reset.waitForExistence(timeout: 15))
    }

    private func openPunjabColoring() {
        let stateCard = app.buttons["state_card_punjab"]
        XCTAssertTrue(stateCard.waitForExistence(timeout: 10))
        stateCard.tap()

        let colorActivity = app.buttons["color_activity_button"]
        for _ in 0..<4 where !colorActivity.isHittable { app.swipeUp() }
        XCTAssertTrue(colorActivity.waitForExistence(timeout: 10))
        colorActivity.tap()
    }
}

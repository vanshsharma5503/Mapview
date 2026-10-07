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

    func testZoomControlsAreAvailable() {
        openPunjabColoring()
        let zoomIn = app.buttons["coloring_zoom_in"]
        let zoomReset = app.buttons["coloring_zoom_reset"]
        let zoomOut = app.buttons["coloring_zoom_out"]

        XCTAssertTrue(zoomIn.waitForExistence(timeout: 15))
        XCTAssertTrue(zoomReset.exists)
        XCTAssertTrue(zoomOut.exists)
        zoomIn.tap()
        let enabled = NSPredicate(format: "isEnabled == true")
        expectation(for: enabled, evaluatedWith: zoomOut)
        waitForExpectations(timeout: 3)
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
        let searchField = app.textFields["state_search_field"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 10))
        searchField.tap()
        searchField.typeText("Punjab")

        let stateCard = app.buttons["state_card_punjab"]
        XCTAssertTrue(stateCard.waitForExistence(timeout: 10))
        XCTAssertTrue(stateCard.isHittable)
        stateCard.tap()

        let colorActivity = app.buttons["color_activity_button"]
        for _ in 0..<4 where !colorActivity.isHittable { app.swipeUp() }
        XCTAssertTrue(colorActivity.waitForExistence(timeout: 10))
        XCTAssertTrue(colorActivity.isHittable)
        colorActivity.tap()

        XCTAssertTrue(
            app.otherElements["coloring_page"].waitForExistence(timeout: 15),
            "Coloring page should finish navigation before controls are queried."
        )
        XCTAssertTrue(
            app.buttons["coloring_tool_fill"].waitForExistence(timeout: 30),
            "Coloring engine should finish preparing before controls are queried."
        )
    }
}

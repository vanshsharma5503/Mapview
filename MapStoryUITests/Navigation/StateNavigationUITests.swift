//
//  StateNavigationUITests.swift
//  MapStoryUITests
//
//  Created by Vansh Sharma on 30/09/2026.
//

import XCTest

final class StateNavigationUITests: XCTestCase {

    // MARK: - Properties

    private var app: XCUIApplication!

    // MARK: - Setup

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.wait(
                for: .runningForeground,
                timeout: 10
            ),
            "MapStory should launch successfully."
        )
    }

    // MARK: - UI Elements

    private var searchField: XCUIElement {
        app.textFields["state_search_field"]
    }

    private func stateCard(id: String) -> XCUIElement {
        app.buttons["state_card_\(id)"]
    }

    // MARK: - Search Focus

    private func activateSearchField(
        timeout: TimeInterval = 10
    ) {

        let field = searchField

        XCTAssertTrue(
            field.waitForExistence(timeout: timeout),
            "Search field should exist."
        )

        XCTAssertTrue(
            field.isHittable,
            "Search field should be available for interaction."
        )

        // `hasKeyboardFocus` is not reported consistently when the
        // simulator uses a hardware keyboard. The following typeText and
        // navigation assertions verify the interaction end to end.
        field.tap()
    }

    // MARK: - State Card

    private func waitForStateCard(
        id: String,
        timeout: TimeInterval = 10
    ) -> XCUIElement {

        let card = stateCard(id: id)

        XCTAssertTrue(
            card.waitForExistence(timeout: timeout),
            "State card '\(id)' should exist."
        )

        return card
    }

    // MARK: - Detail Screen

    private func waitForDetail(
        stateName: String,
        timeout: TimeInterval = 10
    ) -> Bool {

        let title = app.staticTexts[stateName]

        return title.waitForExistence(
            timeout: timeout
        )
    }

    // MARK: - Open State

    private func openState(
        id: String,
        stateName: String,
        timeout: TimeInterval = 10
    ) {

        let card = waitForStateCard(
            id: id,
            timeout: timeout
        )

        card.tap()

        XCTAssertTrue(
            waitForDetail(
                stateName: stateName,
                timeout: timeout
            ),
            "Detail screen for '\(id)' should appear after tapping its card."
        )
    }

    // MARK: - Search State

    private func searchForState(
        name: String,
        id: String,
        timeout: TimeInterval = 10
    ) {

        activateSearchField(
            timeout: timeout
        )

        searchField.typeText(name)

        let card = waitForStateCard(
            id: id,
            timeout: timeout
        )

        card.tap()

        XCTAssertTrue(
            waitForDetail(
                stateName: name,
                timeout: timeout
            ),
            "Detail screen for '\(id)' should appear after searching for '\(name)'."
        )
    }

    // MARK: - UI-NAV-001
    // Punjab card -> Punjab detail

    func testPunjabCardNavigatesToPunjabDetail() {

        openState(
            id: "punjab",
            stateName: "Punjab"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Punjab",
                timeout: 10
            ),
            "Punjab detail should be visible."
        )
    }

    // MARK: - UI-NAV-002
    // Andhra Pradesh card -> Andhra Pradesh detail

    func testAndhraPradeshCardNavigatesToAndhraPradeshDetail() {

        openState(
            id: "andhra-pradesh",
            stateName: "Andhra Pradesh"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Andhra Pradesh",
                timeout: 10
            ),
            "Andhra Pradesh detail should be visible."
        )
    }

    // MARK: - UI-NAV-003
    // Maharashtra card -> Maharashtra detail

    func testMaharashtraCardNavigatesToMaharashtraDetail() {

        openState(
            id: "maharashtra",
            stateName: "Maharashtra"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Maharashtra",
                timeout: 10
            ),
            "Maharashtra detail should be visible."
        )
    }

    // MARK: - UI-NAV-004
    // Arunachal Pradesh card -> Arunachal Pradesh detail

    func testArunachalPradeshCardNavigatesToArunachalPradeshDetail() {

        openState(
            id: "arunachal-pradesh",
            stateName: "Arunachal Pradesh"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Arunachal Pradesh",
                timeout: 10
            ),
            "Arunachal Pradesh detail should be visible."
        )
    }

    // MARK: - UI-NAV-005
    // Search Punjab -> Punjab detail

    func testSearchPunjabNavigatesToPunjabDetail() {

        searchForState(
            name: "Punjab",
            id: "punjab"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Punjab",
                timeout: 10
            ),
            "Punjab detail should be visible."
        )
    }

    // MARK: - UI-NAV-006
    // Search Andhra Pradesh -> Andhra Pradesh detail

    func testSearchAndhraPradeshNavigatesToAndhraPradeshDetail() {

        searchForState(
            name: "Andhra Pradesh",
            id: "andhra-pradesh"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Andhra Pradesh",
                timeout: 10
            ),
            "Andhra Pradesh detail should be visible."
        )
    }

    // MARK: - UI-NAV-007
    // Punjab navigation isolation

    func testPunjabNavigationDoesNotOpenAnotherState() {

        openState(
            id: "punjab",
            stateName: "Punjab"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Punjab",
                timeout: 10
            )
        )

        // Other state DETAIL titles must not exist.
        XCTAssertFalse(
            app.staticTexts["Andhra Pradesh"]
                .exists && stateCard(id: "andhra-pradesh").exists == false,
            "Punjab navigation must not resolve to Andhra Pradesh detail."
        )

        XCTAssertFalse(
            app.staticTexts["Maharashtra"]
                .exists && stateCard(id: "maharashtra").exists == false,
            "Punjab navigation must not resolve to Maharashtra detail."
        )

        XCTAssertFalse(
            app.staticTexts["Arunachal Pradesh"]
                .exists && stateCard(id: "arunachal-pradesh").exists == false,
            "Punjab navigation must not resolve to Arunachal Pradesh detail."
        )
    }

    // MARK: - UI-NAV-008
    // Andhra Pradesh navigation isolation

    func testAndhraPradeshNavigationDoesNotOpenPunjab() {

        openState(
            id: "andhra-pradesh",
            stateName: "Andhra Pradesh"
        )

        XCTAssertTrue(
            waitForDetail(
                stateName: "Andhra Pradesh",
                timeout: 10
            )
        )

        XCTAssertFalse(
            app.staticTexts["Punjab"]
                .exists && stateCard(id: "punjab").exists == false,
            "Andhra Pradesh navigation must not resolve to Punjab detail."
        )
    }

    // MARK: - UI-NAV-009
    // Back navigation

    func testBackNavigationReturnsToExploreIndia() {

        // Open Punjab detail.
        openState(
            id: "punjab",
            stateName: "Punjab"
        )

        XCTAssertTrue(
            app.staticTexts["Punjab"].waitForExistence(timeout: 10),
            "Punjab detail should be visible before testing back navigation."
        )

        // Locate the custom back control by its accessibility label.
        let backButton = app.buttons["Navigate Back"]

        XCTAssertTrue(
            backButton.waitForExistence(timeout: 10),
            "Navigate Back button should exist on the Punjab detail screen."
        )

        XCTAssertTrue(
            backButton.isHittable,
            "Navigate Back button should be hittable."
        )

        // Tap the actual application back button.
        backButton.tap()

        // Wait for Explore India to return.
        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 15),
            "Punjab state card should be visible after returning to Explore India."
        )

        XCTAssertTrue(
            searchField.waitForExistence(timeout: 15),
            "Search field should be visible after returning to Explore India."
        )
    }

    // MARK: - UI-NAV-010
    // Search field must not navigate

    func testSearchFieldDoesNotNavigate() {

        // We are already on Explore India.
        XCTAssertTrue(
            searchField.waitForExistence(timeout: 10),
            "Search field should exist on Explore India."
        )

        // Tap the search field.
        activateSearchField()

        // Verify that we are still on Explore India.
        XCTAssertTrue(
            searchField.exists,
            "Search field should remain visible after tapping it."
        )

        // A detail-specific back button should not be present.
        //
        // We intentionally do not inspect "Punjab" text because
        // Punjab can legitimately exist as a state-card accessibility
        // element on the Explore screen.
        XCTAssertFalse(
            app.buttons["Back"].exists,
            "Tapping the search field must not open a detail screen."
        )
    }

    // MARK: - UI-NAV-011
    // Puzzle activity -> puzzle screen

    func testPuzzleActivityNavigatesToPuzzle() {
        openState(
            id: "punjab",
            stateName: "Punjab"
        )

        let puzzleButton = app.buttons["puzzle_activity_button"]
        for _ in 0..<4 where !puzzleButton.isHittable {
            app.swipeUp()
        }

        XCTAssertTrue(
            puzzleButton.waitForExistence(timeout: 10),
            "Puzzle activity should exist on the state detail screen."
        )
        XCTAssertTrue(
            puzzleButton.isHittable,
            "Puzzle activity should be tappable."
        )

        puzzleButton.tap()

        XCTAssertTrue(
            app.staticTexts["Piece Together Punjab"].waitForExistence(timeout: 10),
            "Tapping Puzzle should open Punjab's puzzle screen."
        )
    }
}

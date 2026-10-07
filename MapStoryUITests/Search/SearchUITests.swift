//
//  SearchUITests.swift
//  MapStoryUITests
//
//  Created by Vansh Sharma on 30/09/2026.
//

import XCTest

final class SearchUITests: XCTestCase {

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

    private var clearSearchButton: XCUIElement {
        app.buttons["clear_search_button"]
    }

    private func stateCard(
        id: String
    ) -> XCUIElement {

        app.buttons["state_card_\(id)"]
    }

    // MARK: - Search Focus Helper

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
        // simulator uses a hardware keyboard. Typing and the resulting
        // filtered content provide the reliable end-to-end assertion.
        field.tap()
    }

    // MARK: - Basic Search Tests

    /// Verifies that the search field is available
    /// on the Explore India screen.

    func testSearchFieldExists() {

        XCTAssertTrue(
            searchField.waitForExistence(timeout: 10),
            "Search field should be visible on the Explore India screen."
        )
    }

    /// Verifies that searching for Punjab displays
    /// the Punjab state card.

    func testSearchPunjabShowsPunjabCard() {

        activateSearchField()

        searchField.typeText("Punjab")

        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 10),
            "Punjab card should appear after searching for Punjab."
        )
    }

    /// Verifies that searching for Andhra Pradesh
    /// displays the correct Andhra Pradesh state card.

    func testSearchAndhraPradeshShowsCorrectCard() {

        activateSearchField()

        searchField.typeText("Andhra Pradesh")

        XCTAssertTrue(
            stateCard(id: "andhra-pradesh").waitForExistence(timeout: 10),
            "Andhra Pradesh card should appear after searching."
        )
    }

    /// Verifies that searching for Maharashtra
    /// displays the correct Maharashtra state card.

    func testSearchMaharashtraShowsCorrectCard() {

        activateSearchField()

        searchField.typeText("Maharashtra")

        XCTAssertTrue(
            stateCard(id: "maharashtra").waitForExistence(timeout: 10),
            "Maharashtra card should appear after searching."
        )
    }

    /// Verifies that searching for Arunachal Pradesh
    /// displays the correct Arunachal Pradesh state card.

    func testSearchArunachalPradeshShowsCorrectCard() {

        activateSearchField()

        searchField.typeText("Arunachal Pradesh")

        XCTAssertTrue(
            stateCard(id: "arunachal-pradesh").waitForExistence(timeout: 10),
            "Arunachal Pradesh card should appear after searching."
        )
    }

    // MARK: - Invalid Search

    /// Verifies that an invalid search does not display
    /// a state card and instead displays the
    /// "No states found" message.

    func testInvalidSearchShowsNoResults() {

        activateSearchField()

        searchField.typeText("DefinitelyNotAState")

        let noResultsMessage = app.staticTexts["No states found"]

        XCTAssertTrue(
            noResultsMessage.waitForExistence(timeout: 10),
            "The 'No states found' message should appear for an invalid search."
        )
    }

    // MARK: - Clear Search

    /// Verifies that the clear button appears when text
    /// is entered and that tapping it removes the search text.

    func testClearSearch() {

        // Activate search field.
        activateSearchField()

        // Enter Punjab.
        searchField.typeText("Punjab")

        // Verify clear button appears.
        XCTAssertTrue(
            clearSearchButton.waitForExistence(timeout: 10),
            "Clear button should appear after entering search text."
        )

        // Verify Punjab is currently filtered.
        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 10),
            "Punjab should appear while searching for Punjab."
        )

        // Tap clear button.
        clearSearchButton.tap()

        // Clear button should disappear.
        XCTAssertFalse(
            clearSearchButton.waitForExistence(timeout: 2),
            "Clear button should disappear after clearing the search."
        )

        // Clearing restores the alphabetically ordered, unfiltered list.
        XCTAssertTrue(
            stateCard(id: "andhra-pradesh").waitForExistence(timeout: 10),
            "The first alphabetic state should be visible after clearing the search."
        )
        XCTAssertTrue(
            stateCard(id: "arunachal-pradesh").waitForExistence(timeout: 10),
            "The unfiltered list should contain the next alphabetic state."
        )

        // Verify a state outside the initial viewport is available again by
        // filtering for it, rather than assuming every lazy-grid row exists.
        activateSearchField()
        searchField.typeText("Maharashtra")
        XCTAssertTrue(
            stateCard(id: "maharashtra").waitForExistence(timeout: 10),
            "Maharashtra should be available after clearing and searching again."
        )
    }

    // MARK: - Case Sensitivity

    /// Verifies that search works regardless
    /// of letter casing.

    func testSearchIsCaseInsensitive() {

        activateSearchField()

        searchField.typeText("punjab")

        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 10),
            "Searching with lowercase text should find Punjab."
        )
    }

    // MARK: - Partial Search

    /// Verifies that entering part of a state name
    /// returns the matching state.

    func testPartialSearchFindsPunjab() {

        activateSearchField()

        searchField.typeText("Pun")

        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 10),
            "Partial search should find Punjab."
        )
    }

    // MARK: - Search Result Isolation

    /// Verifies that searching for Punjab does not display
    /// unrelated states.

    func testPunjabSearchDoesNotShowUnrelatedStates() {

        activateSearchField()

        searchField.typeText("Punjab")

        XCTAssertTrue(
            stateCard(id: "punjab").waitForExistence(timeout: 10),
            "Punjab should appear in the search results."
        )

        XCTAssertFalse(
            stateCard(id: "andhra-pradesh").exists,
            "Andhra Pradesh should not appear when searching for Punjab."
        )

        XCTAssertFalse(
            stateCard(id: "maharashtra").exists,
            "Maharashtra should not appear when searching for Punjab."
        )

        XCTAssertFalse(
            stateCard(id: "arunachal-pradesh").exists,
            "Arunachal Pradesh should not appear when searching for Punjab."
        )
    }
}

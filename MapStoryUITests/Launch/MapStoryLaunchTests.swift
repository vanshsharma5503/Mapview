//
//  MapStoryLaunchTests.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/09/26.
//


import XCTest

final class MapStoryLaunchTests: XCTestCase {

    func testAppLaunches() throws {

        let app = XCUIApplication()

        app.launch()

        XCTAssertTrue(
            app.wait(for: .runningForeground, timeout: 5),
            "MapStory should launch successfully."
        )
    }
}
//
//  GroceryStoreMapUITests.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 5/12/25.
//

import XCTest

final class GroceryStoreMapUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launchEnvironment["UITestStartScreen"] = "map"
        app.launch()
    }

    func testMapIsZoomable() {
        let map = app.otherElements["MainMap"]

        // Ensure the map exists
        XCTAssertTrue(map.waitForExistence(timeout: 5), "Map should exist on screen")

        // Perform a pinch out to zoom in
        map.pinch(withScale: 2.0, velocity: 1.0)
        sleep(1) // Wait for zoom animation to finish

        // Perform a pinch in to zoom out
        map.pinch(withScale: 0.5, velocity: -1.0)
        sleep(1)

        // MapKit does not expose zoom level directly to UI tests.
        // So this test mainly ensures gestures are recognized and don't crash.
    }

}

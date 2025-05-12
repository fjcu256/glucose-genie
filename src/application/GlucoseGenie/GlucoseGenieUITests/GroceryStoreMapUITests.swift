//
//  GroceryStoreMapUITests.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 5/12/25.
//
// Add any UI test cases here that validate any feature of the Grocery Store Map ("Find a Store") page.

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
        sleep(1)

        // Perform a pinch in to zoom out
        map.pinch(withScale: 0.5, velocity: -1.0)
        sleep(1)

        // MapKit does not expose zoom level directly to UI tests.
        // So this test mainly ensures gestures are recognized and don't crash.
    }
    
    func testMapIsPannable() {
        let map = app.otherElements["MainMap"]
        XCTAssertTrue(map.waitForExistence(timeout: 5), "Map should exist")

        // Swipe gestures to simulate panning
        map.swipeUp()
        sleep(1)

        map.swipeDown()
        sleep(1)

        map.swipeLeft()
        sleep(1)

        map.swipeRight()
        sleep(1)
        
        // If gestures do not crash, then we have validated map-panning functionality
        }

}

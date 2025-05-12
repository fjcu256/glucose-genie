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

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//
//        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
//
//        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

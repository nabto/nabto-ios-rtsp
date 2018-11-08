//
//  Nabto_RTSP_UITests.swift
//  Nabto RTSP UITests
//
//  Created by Ulrik Gammelby on 08/11/2018.
//  Copyright © 2018 MRodalgaard. All rights reserved.
//

import XCTest


class Nabto_RTSP_UITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["clean"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func enterText(element: String, content: String) {
        let textField = XCUIApplication().tables.textFields[element]
        textField.tap();
        textField.typeText(content);
    }
    
    func testVideoPlayer() {
        XCUIDevice.shared.orientation = .portrait

        let app = XCUIApplication()
        app.buttons["Add Device"].tap()
        enterText(element: "My Device [optional]", content: "test device")
        enterText(element: "demo.nabto.net",       content: "1.axis.nabto.net")
        enterText(element: "80",                   content: "554")
        enterText(element: "/",                    content: "axis-media/media.amp")
        app.navigationBars["Video Device"].buttons["Save"].tap()
        app.tables.staticTexts["test device"].tap();

        var exp = expectation(description: "Show a few seconds of video in default orientation")
        XCTWaiter.wait(for: [exp], timeout: 5.0)

        XCUIDevice.shared.orientation = .landscapeLeft
        exp = expectation(description: "Show a few seconds of video in rotated orientation")
        XCTWaiter.wait(for: [exp], timeout: 5.0)

        app.otherElements.containing(.navigationBar, identifier:"VideoPageView").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.tap()
        exp = expectation(description: "Show a few seconds of full screen video")
        XCTWaiter.wait(for: [exp], timeout: 5.0)
    }
}

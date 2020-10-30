//
//  Tabby_the_CopycatUITests.swift
//  Tabby the CopycatUITests
//
//  Created by Ryan on 10/29/20.
//  Copyright © 2020 Wingover. All rights reserved.
//

import XCTest

class Tabby_the_CopycatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testInstallScreenScreenshot_CatalinaState() throws {
        let app = XCUIApplication()
        app.launchArguments = ["TestCatalinaBugResponse"]
        app.launch()
        let installScreen = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: installScreen)
        attachment.lifetime = .keepAlways
        attachment.name = "CatalinaState"
        add(attachment)
    }

    func testInstallScreenScreenshot_NonCatalinaState() throws {
        let app = XCUIApplication()
        app.launch()
        let installScreen = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: installScreen)
        attachment.lifetime = .keepAlways
        attachment.name = "NonCatalinaState"
        add(attachment)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, *) {
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

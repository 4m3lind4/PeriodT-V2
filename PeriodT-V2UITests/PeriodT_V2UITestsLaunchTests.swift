//
//  PeriodT_V2UITestsLaunchTests.swift
//  PeriodT-V2UITests
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//
//  Takes a launch screenshot for each configuration.
//

import XCTest

final class PeriodT_V2UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        // Sample data rather than Supabase, so screenshots are consistent between runs.
        app.launchArguments = ["-UITesting"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Good Morning!"].waitForExistence(timeout: 10))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

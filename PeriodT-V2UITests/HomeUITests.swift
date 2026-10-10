//
//  HomeUITests.swift
//  PeriodT-V2UITests
//

import XCTest

final class HomeUITests: PeriodTUITestCase {

    @MainActor
    func testAppLaunchesOnHomeWithAllTabs() {
        for tab in [Tab.home, .calendar, .exercise, .journal] {
            XCTAssertTrue(tabButton(tab).waitForExistence(timeout: timeout), "\(tab.rawValue) tab missing")
        }
        XCTAssertTrue(tabButton(.home).isSelected)
        XCTAssertTrue(app.staticTexts["Good Morning!"].waitForExistence(timeout: timeout))
    }

    @MainActor
    func testHomeShowsCycleRingFromLoggedPeriod() {
        // Sample data logs a period ending yesterday: 27 days to go, menstrual phase.
        XCTAssertTrue(app.staticTexts["Period in"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["27"].exists)
        XCTAssertTrue(app.staticTexts["Menstrual Phase"].exists)
    }

    @MainActor
    func testHomeShowsProgramsFromRepository() {
        let heading = app.staticTexts["Today Programs"]
        XCTAssertTrue(heading.waitForExistence(timeout: timeout))
        scrollTo(heading)
        // Cards are loaded from the repository, so the empty-state card shouldn't show.
        XCTAssertTrue(text(containing: "Day 3").waitForExistence(timeout: timeout))
        XCTAssertFalse(text(containing: "No Exercises due!").exists)
    }

    @MainActor
    func testAnsweringPollQuestionMarksItSelected() {
        let yes = app.buttons.matching(identifier: "Yes").firstMatch
        let no = app.buttons.matching(identifier: "No").firstMatch
        scrollTo(yes)
        XCTAssertFalse(yes.isSelected)

        yes.tap()
        XCTAssertTrue(yes.isSelected)
        XCTAssertFalse(no.isSelected)

        no.tap()
        XCTAssertTrue(no.isSelected)
        XCTAssertFalse(yes.isSelected)
    }

    @MainActor
    func testSelectingEmotionIsExclusive() {
        let happy = app.buttons["Happy"]
        let calm = app.buttons["Calm"]
        scrollTo(happy)

        happy.tap()
        XCTAssertTrue(happy.isSelected)

        calm.tap()
        XCTAssertTrue(calm.isSelected)
        XCTAssertFalse(happy.isSelected)
    }

    @MainActor
    func testIntensitySliderIsAdjustable() {
        // The control, not the visible title text above it.
        let slider = app.descendants(matching: .any).matching(NSPredicate(
            format: "label == %@ AND elementType != %d",
            "Emotional Intensity", XCUIElement.ElementType.staticText.rawValue
        )).firstMatch
        scrollTo(slider)
        XCTAssertEqual(slider.value as? String, "3 of 5")

        slider.swipeRight()
        XCTAssertEqual(slider.value as? String, "5 of 5")

        slider.swipeLeft()
        XCTAssertEqual(slider.value as? String, "1 of 5")
    }

    @MainActor
    func testJournalTextIsKeptAfterTyping() {
        let editor = app.textViews.firstMatch
        scrollTo(editor)
        editor.tap()
        editor.typeText("Felt great")
        XCTAssertEqual(editor.value as? String, "Felt great")
    }

    /// Logging today's period on Home should update the Calendar tab's countdown.
    @MainActor
    func testLoggingPeriodOnHomeUpdatesCalendarCountdown() {
        open(.calendar)
        XCTAssertTrue(app.staticTexts["27 Days"].waitForExistence(timeout: timeout))

        open(.home)
        // Second question is "Were you on your period?".
        let onPeriodYes = app.buttons.matching(identifier: "Yes").element(boundBy: 1)
        scrollTo(onPeriodYes)
        onPeriodYes.tap()
        XCTAssertTrue(onPeriodYes.isSelected)

        // Wait out the save delay so the tab switch's reload sees the saved answer.
        sleep(2)
        open(.calendar)
        XCTAssertTrue(app.staticTexts["28 Days"].waitForExistence(timeout: timeout))
    }

    @MainActor
    func testSubmitScrollsBackToTop() {
        let submit = app.buttons["Submit"]
        scrollTo(submit)
        submit.tap()
        XCTAssertTrue(app.staticTexts["Good Morning!"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Good Morning!"].isHittable)
    }
}

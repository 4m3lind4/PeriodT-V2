//
//  CalendarUITests.swift
//  PeriodT-V2UITests
//

import XCTest

final class CalendarUITests: PeriodTUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        open(.calendar)
    }

    private func day(_ offset: Int) -> XCUIElement {
        app.buttons[calendarDayIdentifier(daysFromToday: offset)]
    }

    @MainActor
    func testPeriodDueCountdownShowsFromSampleData() {
        XCTAssertTrue(app.staticTexts["Period Due"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["27 Days"].exists)
    }

    @MainActor
    func testCalendarOpensOnCurrentMonth() {
        let today = day(0)
        XCTAssertTrue(today.waitForExistence(timeout: timeout))
        XCTAssertTrue(today.isHittable, "Calendar should scroll to today's month on appear")
    }

    @MainActor
    func testDayCellsHaveFullDateAccessibilityLabels() {
        let today = day(0)
        XCTAssertTrue(today.waitForExistence(timeout: timeout))
        let year = String(Calendar.current.component(.year, from: Date()))
        XCTAssertTrue(today.label.contains(year), "Expected a full date, got \"\(today.label)\"")
    }

    @MainActor
    func testTappingTodayOpensDaySheetWithTodaysProgram() {
        let today = day(0)
        XCTAssertTrue(today.waitForExistence(timeout: timeout))
        today.tap()

        XCTAssertTrue(app.staticTexts["My Programs"].waitForExistence(timeout: timeout))
        XCTAssertTrue(text(containing: "Day 3").exists)
        XCTAssertTrue(app.staticTexts["No review logged for this day"].exists)
        XCTAssertTrue(app.buttons["Add review"].exists)

        app.buttons["Close"].tap()
        XCTAssertTrue(waitForNonExistence(app.staticTexts["My Programs"]))
    }

    @MainActor
    func testTappingLoggedDayShowsReviewSummaryAndPhase() {
        let yesterday = day(-1)
        XCTAssertTrue(yesterday.waitForExistence(timeout: timeout))
        yesterday.tap()

        XCTAssertTrue(app.staticTexts["Menstrual Phase"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Did you practice today?"].exists)
        XCTAssertTrue(app.buttons["Edit review"].exists)

        // Two summary cards show until View More.
        let viewMore = app.buttons["View More"]
        XCTAssertTrue(viewMore.exists)
        XCTAssertFalse(app.staticTexts["Emotions"].exists)
        viewMore.tap()
        XCTAssertTrue(app.staticTexts["Emotions"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["View Less"].exists)
    }

    @MainActor
    func testTappingFutureDayShowsErrorCardThatAutoDismisses() {
        let tomorrow = day(1)
        XCTAssertTrue(tomorrow.waitForExistence(timeout: timeout))
        scrollTo(tomorrow)
        tomorrow.tap()

        let error = anyElement(containing: "not available yet")
        XCTAssertTrue(error.waitForExistence(timeout: timeout))
        XCTAssertFalse(app.staticTexts["My Programs"].exists, "Future days shouldn't open the sheet")
        // Transient errors slide away after ~3 seconds.
        XCTAssertTrue(waitForNonExistence(error, timeout: 8))
    }

    @MainActor
    func testAddingReviewFromDaySheet() {
        let today = day(0)
        XCTAssertTrue(today.waitForExistence(timeout: timeout))
        today.tap()

        let addReview = app.buttons["Add review"]
        XCTAssertTrue(addReview.waitForExistence(timeout: timeout))
        addReview.tap()

        // Editor shows the same poll as Home.
        let trainedYes = app.buttons.matching(identifier: "Yes").firstMatch
        XCTAssertTrue(trainedYes.waitForExistence(timeout: timeout))
        trainedYes.tap()
        XCTAssertTrue(trainedYes.isSelected)

        let submit = app.buttons["Submit"]
        scrollTo(submit)
        submit.tap()

        // Back on the overview, the new answer is summarised and the button now edits.
        XCTAssertTrue(app.buttons["Edit review"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Did you practice today?"].exists)
        XCTAssertFalse(app.staticTexts["No review logged for this day"].exists)
    }
}

//
//  OfflineUITests.swift
//  PeriodT-V2UITests
//
//  Every repository call fails here (`-UITestingOffline`), so each screen
//  should fall back to its empty state instead of crashing or hanging.
//

import XCTest

final class OfflineUITests: PeriodTUITestCase {
    override var extraLaunchArguments: [String] { ["-UITestingOffline"] }

    @MainActor
    func testHomeShowsEmptyStates() {
        XCTAssertTrue(app.staticTexts["Log your period"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Not logged"].exists)
        let noPrograms = text(containing: "No Exercises due!")
        scrollTo(noPrograms)
        XCTAssertTrue(noPrograms.exists)
    }

    @MainActor
    func testCalendarShowsNotLogged() {
        open(.calendar)
        XCTAssertTrue(app.staticTexts["Period Due"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Not logged"].exists)
    }

    @MainActor
    func testExerciseShowsLoadErrorInsteadOfRestDay() {
        open(.exercise)
        XCTAssertTrue(app.staticTexts["Couldn't load your programs. Pull down to try again."].waitForExistence(timeout: timeout))
        XCTAssertFalse(app.staticTexts["Rest day - nothing scheduled"].exists)
        XCTAssertFalse(app.staticTexts["Incoming"].exists)
        XCTAssertFalse(app.staticTexts["Completed"].exists)
    }

    @MainActor
    func testJournalShowsNoEntries() {
        open(.journal)
        let empty = app.staticTexts["No entries yet"]
        XCTAssertTrue(empty.waitForExistence(timeout: timeout))
    }

    @MainActor
    func testFailedJournalSaveShowsErrorCard() {
        open(.journal)
        let addEntry = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add new entry")).firstMatch
        scrollTo(addEntry)
        addEntry.tap()

        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: timeout))
        editor.tap()
        editor.typeText("Offline note")
        app.buttons["Save"].tap()

        XCTAssertTrue(anyElement(containing: "Something went wrong saving your journal").waitForExistence(timeout: timeout))
    }

    @MainActor
    func testFailedReviewSaveShowsErrorCardOnHome() {
        let yes = app.buttons.matching(identifier: "Yes").firstMatch
        scrollTo(yes)
        yes.tap()
        XCTAssertTrue(anyElement(containing: "Something went wrong saving your answer").waitForExistence(timeout: timeout))
    }
}

//
//  JournalUITests.swift
//  PeriodT-V2UITests
//

import XCTest

final class JournalUITests: PeriodTUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        open(.journal)
        XCTAssertTrue(app.staticTexts["Goals"].waitForExistence(timeout: timeout))
    }

    private var addGoalButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add new goal")).firstMatch
    }

    private var addEntryButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Add new entry")).firstMatch
    }

    @MainActor
    func testGoalsShowTwoUntilViewMore() {
        XCTAssertTrue(text(containing: "GOAL 1").exists)
        XCTAssertTrue(text(containing: "GOAL 2").exists)
        XCTAssertFalse(text(containing: "GOAL 3").exists)

        let viewMore = app.buttons["View More"].firstMatch
        scrollTo(viewMore)
        viewMore.tap()
        XCTAssertTrue(text(containing: "GOAL 3").waitForExistence(timeout: timeout))
    }

    @MainActor
    func testAddingAGoal() {
        addGoalButton.tap()

        let alert = app.alerts["New goal"]
        XCTAssertTrue(alert.waitForExistence(timeout: timeout))
        alert.textFields.firstMatch.typeText("Run 5k")
        alert.buttons["Add"].tap()

        let viewMore = app.buttons["View More"].firstMatch
        scrollTo(viewMore)
        viewMore.tap()
        XCTAssertTrue(text(containing: "GOAL 4").waitForExistence(timeout: timeout))
        XCTAssertTrue(text(containing: "Run 5k").exists)
    }

    @MainActor
    func testBlankGoalIsNotAdded() {
        addGoalButton.tap()
        let alert = app.alerts["New goal"]
        XCTAssertTrue(alert.waitForExistence(timeout: timeout))
        alert.textFields.firstMatch.typeText("   ")
        alert.buttons["Add"].tap()

        let viewMore = app.buttons["View More"].firstMatch
        scrollTo(viewMore)
        viewMore.tap()
        XCTAssertTrue(text(containing: "GOAL 3").waitForExistence(timeout: timeout))
        XCTAssertFalse(text(containing: "GOAL 4").exists)
    }

    @MainActor
    func testEntriesShowMostRecentJournalFirst() {
        // Sample data: yesterday's journal is the newest non-empty one.
        let newest = text(containing: "Feeling better")
        scrollTo(newest)
        XCTAssertTrue(newest.exists)
        XCTAssertFalse(app.staticTexts["No entries yet"].exists)
        // Mood is the card title for emotional entries.
        XCTAssertTrue(app.staticTexts["Calm"].exists)
    }

    @MainActor
    func testTappingEntryOpensItsJournalInTheSheet() {
        let entry = text(containing: "Feeling better")
        scrollTo(entry)
        entry.tap()

        XCTAssertTrue(app.staticTexts["Entries"].waitForExistence(timeout: timeout))
        let editor = app.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: timeout))
        XCTAssertEqual(editor.value as? String, "Feeling better, energy coming back.")
    }

    @MainActor
    func testNewEntryWritesTodaysEmotionalJournal() {
        scrollTo(addEntryButton)
        addEntryButton.tap()

        XCTAssertTrue(app.staticTexts["Entries"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Emotional")).firstMatch.exists)

        let editor = app.textViews.firstMatch
        editor.tap()
        editor.typeText("UI test entry")
        app.buttons["Save"].tap()

        // Close the sheet; the new entry should be listed first.
        app.swipeDown(velocity: .fast)
        XCTAssertTrue(waitForNonExistence(app.staticTexts["Entries"]))
        let newEntry = text(containing: "UI test entry")
        scrollTo(newEntry)
        XCTAssertTrue(newEntry.exists)
    }
}

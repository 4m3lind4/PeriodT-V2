//
//  ExerciseUITests.swift
//  PeriodT-V2UITests
//

import XCTest

final class ExerciseUITests: PeriodTUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        open(.exercise)
        XCTAssertTrue(app.staticTexts["Today's Program"].waitForExistence(timeout: timeout))
    }

    /// Today's sample program is "Day 3" (Hip Thrust, Side Planks, Dumbbell Lunges, Russian Twist).
    private var todaysCard: XCUIElement { text(containing: "Day 3") }

    private func expandTodaysCard() {
        XCTAssertTrue(todaysCard.waitForExistence(timeout: timeout))
        todaysCard.tap()
        XCTAssertTrue(app.staticTexts["Hip Thrust"].waitForExistence(timeout: timeout))
    }

    private func startTodaysProgram() {
        expandTodaysCard()
        let start = app.buttons["Start"]
        scrollTo(start)
        start.tap()
        XCTAssertTrue(text(containing: "Program").waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["Submit"].waitForExistence(timeout: timeout))
    }

    @MainActor
    func testProgramsAreGroupedIntoSections() {
        XCTAssertTrue(todaysCard.waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Incoming"].exists)
        scrollTo(app.staticTexts["Completed"])
        XCTAssertFalse(app.staticTexts["Rest day - nothing scheduled"].exists)
    }

    @MainActor
    func testIncomingViewMoreRevealsThirdProgram() {
        // Incoming sample programs are Day 4, 5 and 6; only two show at first.
        XCTAssertTrue(text(containing: "Day 4").waitForExistence(timeout: timeout))
        XCTAssertFalse(text(containing: "Day 6").exists)

        let viewMore = app.buttons["View More"].firstMatch
        scrollTo(viewMore)
        viewMore.tap()

        XCTAssertTrue(text(containing: "Day 6").waitForExistence(timeout: timeout))
        XCTAssertTrue(app.buttons["View Less"].exists)
    }

    @MainActor
    func testCardExpandsAndCollapses() {
        expandTodaysCard()
        XCTAssertTrue(app.buttons["Start"].exists)

        todaysCard.tap()
        XCTAssertTrue(waitForNonExistence(app.staticTexts["Hip Thrust"]))
        XCTAssertFalse(app.buttons["Start"].exists)
    }

    @MainActor
    func testOnlyOneCardIsExpandedAtATime() {
        expandTodaysCard()
        let incomingCard = text(containing: "Day 4")
        scrollTo(incomingCard)
        incomingCard.tap()

        // Day 4 has Romanian Deadlift; Day 3's Hip Thrust should collapse away.
        XCTAssertTrue(app.staticTexts["Romanian Deadlift"].waitForExistence(timeout: timeout))
        XCTAssertTrue(waitForNonExistence(app.staticTexts["Hip Thrust"]))
    }

    @MainActor
    func testStartingProgramListsItsWorkouts() {
        startTodaysProgram()
        for name in ["Hip Thrust", "Side Planks", "Dumbbell Lunges", "Russian Twist"] {
            XCTAssertTrue(app.staticTexts[name].exists, "\(name) missing")
        }
    }

    @MainActor
    func testTickingASetTogglesIt() {
        startTodaysProgram()
        app.staticTexts["Hip Thrust"].tap()

        let firstSet = app.buttons["Set 1"]
        XCTAssertTrue(firstSet.waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["3 Sets | 10 Second Rest"].exists)
        XCTAssertEqual(firstSet.value as? String, "Not done")

        firstSet.tap()
        XCTAssertEqual(firstSet.value as? String, "Done")

        firstSet.tap()
        XCTAssertEqual(firstSet.value as? String, "Not done")
    }

    @MainActor
    func testFinishingEverySetReturnsToProgram() {
        startTodaysProgram()
        app.staticTexts["Hip Thrust"].tap()

        for index in 1...3 {
            let set = app.buttons["Set \(index)"]
            XCTAssertTrue(set.waitForExistence(timeout: timeout))
            set.tap()
        }

        // The tracker pops itself once the last set is ticked.
        XCTAssertTrue(waitForNonExistence(app.buttons["Set 1"]))
        XCTAssertTrue(app.buttons["Submit"].exists)
    }

    @MainActor
    func testSubmittingProgramShowsCompletionAndReturnsHome() {
        startTodaysProgram()
        let submit = app.buttons["Submit"]
        scrollTo(submit)
        submit.tap()

        XCTAssertTrue(app.staticTexts["Great Job!"].waitForExistence(timeout: timeout))
        XCTAssertTrue(app.staticTexts["Workout Journal"].exists)
        XCTAssertTrue(app.staticTexts["Workout Intensity"].exists)

        let finish = app.buttons["Submit"]
        scrollTo(finish)
        finish.tap()

        // The celebration plays once, then the app jumps back to Home. It can finish
        // between polls, so accept either the celebration or Home having already appeared.
        let celebration = app.staticTexts["Workout Logged"]
        let home = app.staticTexts["Good Morning!"]
        XCTAssertTrue(celebration.waitForExistence(timeout: timeout) || home.exists)
        XCTAssertTrue(home.waitForExistence(timeout: 20))
        XCTAssertTrue(tabButton(.home).isSelected)

        // The exercise stack was cleared, so the tab shows the list again.
        open(.exercise)
        XCTAssertTrue(app.staticTexts["Today's Program"].waitForExistence(timeout: timeout))
    }
}

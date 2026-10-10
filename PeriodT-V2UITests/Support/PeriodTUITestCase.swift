//
//  PeriodTUITestCase.swift
//  PeriodT-V2UITests
//
//  Base class: launches the app against `MockPeriodTRepository` (via `-UITesting`)
//  so tests are deterministic and never touch Supabase.
//

import XCTest

class PeriodTUITestCase: XCTestCase {
    var app: XCUIApplication!

    /// Extra launch arguments for a subclass, e.g. `-UITestingOffline`.
    var extraLaunchArguments: [String] { [] }

    let timeout: TimeInterval = 10

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITesting"] + extraLaunchArguments
        app.launch()
    }

    override func tearDownWithError() throws {
        if let failureCount = testRun?.failureCount, failureCount > 0 {
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = "Failure - \(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        app = nil
    }

    // MARK: - Navigation

    enum Tab: String {
        case home = "Home", calendar = "Calendar", exercise = "Exercise", journal = "Journal"
    }

    func tabButton(_ tab: Tab) -> XCUIElement {
        app.tabBars.buttons[tab.rawValue]
    }

    func open(_ tab: Tab) {
        let button = tabButton(tab)
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "\(tab.rawValue) tab missing")
        button.tap()
    }

    // MARK: - Queries

    /// Static text whose label contains `text`. Useful where SwiftUI combines labels.
    func text(containing text: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    func anyElement(containing text: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    // MARK: - Scrolling

    /// Swipes the main scroll view until `element` is hittable.
    @discardableResult
    func scrollTo(_ element: XCUIElement, up: Bool = false, maxSwipes: Int = 12,
                  file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            let scrollView = app.scrollViews.firstMatch
            let target: XCUIElement = scrollView.exists ? scrollView : app
            // Drag from the middle rather than swipe so we move a modest, predictable amount.
            let start = target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.35 : 0.7))
            let end = target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.7 : 0.35))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
        XCTAssertTrue(element.isHittable, "Couldn't scroll to \(element)", file: file, line: line)
        return element
    }

    func waitForNonExistence(_ element: XCUIElement, timeout: TimeInterval? = nil) -> Bool {
        element.waitForNonExistence(timeout: timeout ?? self.timeout)
    }

    // MARK: - Dates

    /// Matches `CalendarView.dayIdentifier(for:)`.
    func calendarDayIdentifier(daysFromToday offset: Int) -> String {
        let calendar = Calendar.current
        let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: Date()))!
        let parts = calendar.dateComponents([.year, .month, .day], from: day)
        return String(format: "calendar-day-%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }
}

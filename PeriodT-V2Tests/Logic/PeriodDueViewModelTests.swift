//
//  PeriodDueViewModelTests.swift
//  PeriodT-V2Tests
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("PeriodDueViewModel")
struct PeriodDueViewModelTests {
    private let viewModel = PeriodDueViewModel()

    // MARK: - Last period

    @Test func noReviewsMeansNothingLogged() {
        #expect(viewModel.lastReportedPeriod(in: []) == nil)
        #expect(viewModel.daysUntilNextPeriod(in: []) == nil)
        #expect(viewModel.dueText(for: []) == "Not logged")
        #expect(viewModel.phase(in: []) == "Not logged")
        #expect(viewModel.cycleProgress(in: []) == 0)
    }

    @Test func onlyNoAnswersCountAsNotLogged() {
        let reviews = [Fixtures.review(on: TestDates.daysFromToday(-1), onPeriod: .no)]
        #expect(viewModel.lastReportedPeriod(in: reviews) == nil)
    }

    @Test func lastReportedPeriodIsMostRecentYes() {
        let reviews = [
            Fixtures.period(daysAgo: 10),
            Fixtures.period(daysAgo: 3),
            Fixtures.review(on: TestDates.daysFromToday(-1), onPeriod: .no),
            Fixtures.period(daysAgo: 6)
        ]
        #expect(viewModel.lastReportedPeriod(in: reviews) == TestDates.daysFromToday(-3))
    }

    // MARK: - Countdown copy

    @Test(arguments: [
        (1, 27, "27 Days"),
        (27, 1, "1 Day"),
        (28, 0, "Due today"),
        (29, -1, "Overdue by 1 Day"),
        (31, -3, "Overdue by 3 Days")
    ])
    func countdown(daysAgo: Int, expectedDays: Int, expectedText: String) {
        let reviews = [Fixtures.period(daysAgo: daysAgo)]
        #expect(viewModel.daysUntilNextPeriod(in: reviews) == expectedDays)
        #expect(viewModel.dueText(for: reviews) == expectedText)
    }

    @Test func customCycleLength() {
        let viewModel = PeriodDueViewModel(cycleLength: 35)
        #expect(viewModel.dueText(for: [Fixtures.period(daysAgo: 5)]) == "30 Days")
    }

    // MARK: - Ring progress

    @Test func progressIsShareOfCycleRemaining() {
        #expect(viewModel.cycleProgress(in: [Fixtures.period(daysAgo: 0)]) == 1)
        #expect(viewModel.cycleProgress(in: [Fixtures.period(daysAgo: 14)]) == 0.5)
        #expect(viewModel.cycleProgress(in: [Fixtures.period(daysAgo: 28)]) == 0)
    }

    @Test func progressIsClampedToZeroAndOne() {
        #expect(viewModel.cycleProgress(in: [Fixtures.period(daysAgo: 40)]) == 0)
        // A period logged in the future pushes the countdown past a full cycle.
        #expect(viewModel.cycleProgress(in: [Fixtures.period(daysAgo: -3)]) == 1)
    }

    // MARK: - Phase label

    @Test(arguments: [
        (0, "Menstrual Phase"), (4, "Menstrual Phase"),
        (5, "Follicular Phase"), (12, "Follicular Phase"),
        (13, "Ovulation Phase"), (15, "Ovulation Phase"),
        (16, "Luteal Phase"), (27, "Luteal Phase")
    ])
    func phaseLabel(daysAgo: Int, expected: String) {
        #expect(viewModel.phase(in: [Fixtures.period(daysAgo: daysAgo)]) == expected)
    }

    /// Home's ring and the calendar's day sheet should agree on today's phase.
    @Test(arguments: [0, 5, 13, 16, 27])
    func phaseMatchesCyclePhaseWithinACycle(daysAgo: Int) throws {
        let reviews = [Fixtures.period(daysAgo: daysAgo)]
        let cyclePhase = try #require(CyclePhase.current(from: reviews))
        #expect(viewModel.phase(in: reviews) == "\(cyclePhase.rawValue) Phase")
    }

    /// Once a period is overdue, Home keeps saying "Luteal" while `CyclePhase` wraps
    /// round to a new cycle, so the ring and the calendar sheet disagree.
    @Test(arguments: [30, 35, 42])
    func phaseMatchesCyclePhaseWhenOverdue(daysAgo: Int) throws {
        let reviews = [Fixtures.period(daysAgo: daysAgo)]
        let cyclePhase = try #require(CyclePhase.current(from: reviews))
        withKnownIssue("PeriodDueViewModel.phase doesn't wrap overdue cycles like CyclePhase does") {
            #expect(viewModel.phase(in: reviews) == "\(cyclePhase.rawValue) Phase")
        }
    }
}

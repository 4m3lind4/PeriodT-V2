//
//  CyclePhaseTests.swift
//  PeriodT-V2Tests
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("CyclePhase")
struct CyclePhaseTests {

    // MARK: - Day → phase boundaries

    @Test(arguments: [
        (1, CyclePhase.menstrual), (5, .menstrual),
        (6, .follicular), (13, .follicular),
        (14, .ovulation), (16, .ovulation),
        (17, .luteal), (28, .luteal)
    ])
    func cycleDayBoundaries(day: Int, expected: CyclePhase) {
        #expect(CyclePhase(cycleDay: day) == expected)
    }

    @Test(arguments: [CyclePhase.menstrual, .follicular, .ovulation, .luteal])
    func everyPhaseHasAMessageNamingIt(_ phase: CyclePhase) {
        #expect(phase.message.contains("\(phase.rawValue) Phase"))
    }

    // MARK: - phase(on:from:)

    /// A fixed period start well away from DST changes in common time zones.
    private let periodStart = TestDates.date(2026, 6, 1)

    private func phase(daysAfterStart offset: Int, logs: [PollAnswers]? = nil) -> CyclePhase? {
        let logs = logs ?? [Fixtures.review(on: periodStart, onPeriod: .yes)]
        return CyclePhase.phase(on: TestDates.adding(days: offset, to: periodStart), from: logs)
    }

    @Test func noLoggedPeriodGivesNil() {
        #expect(CyclePhase.phase(on: periodStart, from: []) == nil)
        let notOnPeriod = [Fixtures.review(on: periodStart, onPeriod: .no, trained: .yes)]
        #expect(CyclePhase.phase(on: periodStart, from: notOnPeriod) == nil)
    }

    @Test func dayBeforeFirstLoggedPeriodGivesNil() {
        #expect(phase(daysAfterStart: -1) == nil)
    }

    @Test(arguments: [
        (0, CyclePhase.menstrual), (4, .menstrual),
        (5, .follicular), (12, .follicular),
        (13, .ovulation), (15, .ovulation),
        (16, .luteal), (27, .luteal)
    ])
    func phaseCountsFromLoggedPeriod(offset: Int, expected: CyclePhase) {
        #expect(phase(daysAfterStart: offset) == expected)
    }

    @Test func phaseWrapsAfterAFullCycleWithoutLogging() {
        #expect(phase(daysAfterStart: 28) == .menstrual)
        #expect(phase(daysAfterStart: 28 + 13) == .ovulation)
    }

    @Test func usesLatestPeriodOnOrBeforeTheDay() {
        let logs = (0..<5).map { Fixtures.review(on: TestDates.adding(days: $0, to: periodStart), onPeriod: .yes) }
        // Last logged day is day 4, so 5 days after start is cycle day 2.
        #expect(phase(daysAfterStart: 5, logs: logs) == .menstrual)
        // 14 days after the last logged day (cycle day 15).
        #expect(phase(daysAfterStart: 4 + 14, logs: logs) == .ovulation)
    }

    @Test func ignoresPeriodsLoggedAfterTheDay() {
        let logs = [
            Fixtures.review(on: periodStart, onPeriod: .yes),
            Fixtures.review(on: TestDates.adding(days: 20, to: periodStart), onPeriod: .yes)
        ]
        #expect(phase(daysAfterStart: 10, logs: logs) == .follicular)
    }

    @Test func respectsCustomCycleLength() {
        let logs = [Fixtures.review(on: periodStart, onPeriod: .yes)]
        let day = TestDates.adding(days: 30, to: periodStart)
        #expect(CyclePhase.phase(on: day, from: logs, cycleLength: 28) == .menstrual)
        #expect(CyclePhase.phase(on: day, from: logs, cycleLength: 35) == .luteal)
    }

    @Test func currentUsesToday() {
        #expect(CyclePhase.current(from: [Fixtures.period(daysAgo: 0)]) == .menstrual)
        #expect(CyclePhase.current(from: [Fixtures.period(daysAgo: 20)]) == .luteal)
        #expect(CyclePhase.current(from: []) == nil)
    }
}

//
//  NotificationPlannerTests.swift
//  PeriodT-V2Tests
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("NotificationPlanner")
struct NotificationPlannerTests {
    private let planner = NotificationPlanner()

    /// 7am on a fixed day well away from DST changes in common time zones.
    private let now = TestDates.date(2026, 6, 1, hour: 7)

    private func at(_ hour: Int, daysAfterNow offset: Int) -> Date {
        TestDates.adding(days: offset, to: TestDates.date(2026, 6, 1, hour: hour))
    }

    private func plan(reviews: [PollAnswers] = [],
                      programs: [ExerciseProgram] = [],
                      now: Date? = nil) -> [PlannedNotification] {
        planner.plan(reviews: reviews, programs: programs, now: now ?? self.now)
    }

    private func dates(of kind: PlannedNotification.Kind, in plan: [PlannedNotification]) -> [Date] {
        plan.filter { $0.kind == kind }.map(\.fireDate)
    }

    // MARK: - Daily check-in

    @Test func noDataPlansOnlyEveningCheckIns() {
        let plan = plan()
        #expect(plan.allSatisfy { $0.kind == .dailyCheckIn })
        #expect(dates(of: .dailyCheckIn, in: plan) == (0..<14).map { at(20, daysAfterNow: $0) })
    }

    @Test func checkedInDaysAreSkipped() {
        let today = Fixtures.review(on: now, emotion: .happy)
        let tomorrow = Fixtures.review(on: TestDates.adding(days: 1, to: now), trained: .yes)
        let checkIns = dates(of: .dailyCheckIn, in: plan(reviews: [today, tomorrow]))
        #expect(checkIns.first == at(20, daysAfterNow: 2))
        #expect(checkIns.count == 12)
    }

    @Test func emptyReviewIsNotACheckIn() {
        let checkIns = dates(of: .dailyCheckIn, in: plan(reviews: [PollAnswers(date: now)]))
        #expect(checkIns.first == at(20, daysAfterNow: 0))
    }

    @Test func journalOnlyCountsAsCheckIn() {
        #expect(Fixtures.review(on: now, journal: "Tired").hasCheckedIn)
        #expect(!PollAnswers(date: now).hasCheckedIn)
    }

    @Test func nothingIsPlannedInThePast() {
        let lateEvening = TestDates.date(2026, 6, 1, hour: 21)
        let plan = plan(reviews: [Fixtures.review(on: now, onPeriod: .yes)], now: lateEvening)
        #expect(plan.allSatisfy { $0.fireDate > lateEvening })
        #expect(dates(of: .dailyCheckIn, in: plan).first == at(20, daysAfterNow: 1))
    }

    // MARK: - Phase changes

    @Test func phaseChangesFollowTheLoggedPeriod() {
        let plan = plan(reviews: [Fixtures.review(on: now, onPeriod: .yes)])
        // Day 1 menstrual, day 6 follicular, day 14 ovulation, day 17 luteal,
        // then the next cycle starts on day 29 and its follicular phase on day 34.
        #expect(dates(of: .phaseChange, in: plan) == [0, 5, 13, 16, 28, 33].map { at(9, daysAfterNow: $0) })
        let bodies = plan.filter { $0.kind == .phaseChange }.map(\.body)
        #expect(bodies == [CyclePhase.menstrual, .follicular, .ovulation, .luteal, .menstrual, .follicular].map(\.message))
    }

    @Test func noPhaseNotificationsWithoutALoggedPeriod() {
        #expect(dates(of: .phaseChange, in: plan()).isEmpty)
    }

    @Test func consecutivePeriodDaysDontRepeatMenstrual() {
        let reviews = (0..<4).map { Fixtures.review(on: TestDates.adding(days: $0, to: now), onPeriod: .yes) }
        let plan = plan(reviews: reviews)
        // Phases are counted from the most recent period day (day 4 here).
        #expect(dates(of: .phaseChange, in: plan).first == at(9, daysAfterNow: 0))
        #expect(plan.filter { $0.kind == .phaseChange && $0.body == CyclePhase.menstrual.message }.count == 2)
    }

    // MARK: - Period due and overdue

    @Test func periodDueSoonAndOverdue() {
        let plan = plan(reviews: [Fixtures.review(on: now, onPeriod: .yes)])
        // Next period predicted 28 days after the last one.
        #expect(dates(of: .periodDueSoon, in: plan) == [at(9, daysAfterNow: 26)])
        #expect(dates(of: .periodOverdue, in: plan) == [at(9, daysAfterNow: 31)])
    }

    @Test func pastDueReminderIsDroppedButOverdueKept() {
        let lastPeriod = Fixtures.review(on: TestDates.adding(days: -27, to: now), onPeriod: .yes)
        let plan = plan(reviews: [lastPeriod])
        #expect(dates(of: .periodDueSoon, in: plan).isEmpty)
        #expect(dates(of: .periodOverdue, in: plan) == [at(9, daysAfterNow: 4)])
    }

    @Test func noPeriodRemindersWithoutALoggedPeriod() {
        let plan = plan(reviews: [Fixtures.review(on: now, onPeriod: .no)])
        #expect(dates(of: .periodDueSoon, in: plan).isEmpty)
        #expect(dates(of: .periodOverdue, in: plan).isEmpty)
    }

    // MARK: - Workouts

    @Test func unfinishedProgramGetsAMorningReminder() {
        let program = Fixtures.program(on: TestDates.adding(days: 2, to: now))
        let plan = plan(programs: [program])
        #expect(dates(of: .workout, in: plan) == [at(8, daysAfterNow: 2)])
        #expect(plan.first { $0.kind == .workout }?.body.contains("Physio") == true)
    }

    @Test func finishedPastAndEmptyProgramsAreSkipped() {
        var done = Workout(name: "Plank", sets: 3)
        done.isCompleted = true
        let programs = [
            Fixtures.program(on: TestDates.adding(days: 1, to: now), workouts: [done]),
            Fixtures.program(on: TestDates.adding(days: -1, to: now)),
            Fixtures.program(on: TestDates.adding(days: 3, to: now), workouts: [])
        ]
        #expect(dates(of: .workout, in: plan(programs: programs)).isEmpty)
    }

    @Test func partlyFinishedProgramStillReminds() {
        var done = Workout(name: "Plank", sets: 3)
        done.isCompleted = true
        let program = Fixtures.program(on: TestDates.adding(days: 1, to: now),
                                       workouts: [done, Workout(name: "Squat", sets: 3)])
        #expect(dates(of: .workout, in: plan(programs: [program])).count == 1)
    }

    @Test func twoProgramsOnOneDayShareOneReminder() {
        let day = TestDates.adding(days: 1, to: now)
        let plan = plan(programs: [Fixtures.program(on: day), Fixtures.program(on: day, type: .conditioningTraining)])
        let workouts = plan.filter { $0.kind == .workout }
        #expect(workouts.count == 1)
        #expect(workouts.first?.body.contains("2 programs") == true)
    }

    @Test func programsBeyondTheHorizonWait() {
        let program = Fixtures.program(on: TestDates.adding(days: planner.horizonDays + 2, to: now))
        #expect(dates(of: .workout, in: plan(programs: [program])).isEmpty)
    }

    // MARK: - Whole plan

    @Test func planIsSortedUniqueAndUnderTheLimit() {
        let reviews = [Fixtures.review(on: now, onPeriod: .yes)]
        let programs = (0..<50).map { Fixtures.program(on: TestDates.adding(days: $0 % 30, to: now)) }
        let plan = plan(reviews: reviews, programs: programs)
        #expect(plan.count <= planner.maxPending)
        #expect(plan.map(\.fireDate) == plan.map(\.fireDate).sorted())
        #expect(Set(plan.map(\.identifier)).count == plan.count)
        #expect(plan.allSatisfy { $0.identifier.hasPrefix(PlannedNotification.identifierPrefix) })
    }

    @Test func capKeepsTheSoonest() {
        var small = planner
        small.maxPending = 3
        let plan = small.plan(reviews: [], programs: [], now: now)
        #expect(plan.map(\.fireDate) == (0..<3).map { at(20, daysAfterNow: $0) })
    }

    @Test(arguments: [
        (PlannedNotification.Kind.phaseChange, AppNavigationViewModel.Tab.calendar),
        (.periodDueSoon, .calendar), (.periodOverdue, .calendar),
        (.dailyCheckIn, .home), (.workout, .exercise)
    ])
    func tappingOpensTheRightTab(kind: PlannedNotification.Kind, tab: AppNavigationViewModel.Tab) {
        let notification = PlannedNotification(kind: kind, fireDate: now, title: "", body: "")
        #expect(notification.tab == tab)
    }

    @Test func identifierIsStablePerKindAndDay() {
        let morning = PlannedNotification(kind: .workout, fireDate: at(8, daysAfterNow: 0), title: "a", body: "a")
        let evening = PlannedNotification(kind: .workout, fireDate: at(20, daysAfterNow: 0), title: "b", body: "b")
        #expect(morning.identifier == evening.identifier)
        #expect(morning.identifier == "periodt.workout.2026-06-01")
    }

    // MARK: - Inputs

    @Test func inputsIgnoreJournalEditsOnceCheckedIn() {
        let before = NotificationPlanner.Inputs(reviews: [Fixtures.review(on: now, journal: "T")], programs: [])
        let after = NotificationPlanner.Inputs(reviews: [Fixtures.review(on: now, journal: "Tired today")], programs: [])
        #expect(before == after)
    }

    @Test func inputsChangeWhenAPeriodIsLogged() {
        let before = NotificationPlanner.Inputs(reviews: [Fixtures.review(on: now, onPeriod: .no)], programs: [])
        let after = NotificationPlanner.Inputs(reviews: [Fixtures.review(on: now, onPeriod: .yes)], programs: [])
        #expect(before != after)
    }
}

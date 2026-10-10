//
//  CalendarViewModel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//
//  Works out the period highlights on the Calendar tab: days the athlete logged
//  a period, predicted periods and the few days leading up to one.
//

import Foundation
import Combine
import SwiftUI

/// Call `update(with:)` whenever the reviews change.
class CalendarViewModel: ObservableObject {

    @Published var amountOfPrePeriodDays: Int = 3
    /// How long each predicted period lasts. This becomes the athlete's own average
    /// once they've logged one, since everyone's period length is different.
    @Published var amountOfPeriodDays: Int = 6
    /// How many upcoming periods to predict.
    var amountOfPredictedCycles = 2

    /// Same maths as the "Period Due" header and the widget, so all three agree.
    var periodDue = PeriodDueViewModel()

    /// Days the user answered "yes" to being on their period, as `startOfDay`.
    @Published private(set) var loggedPeriodDates: Set<Date> = []
    @Published var prePeriodDates: [Date] = []
    @Published var periodDates: [Date] = []

    /// Held on to so the predictions can be rebuilt from the same logs.
    private var reviews: [PollAnswers] = []

    init(reviews: [PollAnswers] = []) {
        update(with: reviews)
    }

    /// Rebuilds everything from scratch. Order matters here: the first prediction has
    /// to exist before it can be extended, and pre-period days hang off the first one.
    func update(with reviews: [PollAnswers]) {
        self.reviews = reviews
        loggedPeriodDates = Set(reviews
            .filter { $0.answers[.onPeriod] == .yes }
            .map(\.date.startOfDay))
        if let averageLength = averageLoggedPeriodLength() {
            amountOfPeriodDays = averageLength
        }

        calculatePeriodTimes()
        calculateNewMonthPeriod()
        calculatePrePeriodTime()
    }

    func isLoggedPeriodDay(_ day: Date) -> Bool {
        loggedPeriodDates.contains(day.startOfDay)
    }

    func isPrePeriodDay(_ day: Date) -> Bool {
        return prePeriodDates.contains { $0.startOfDay == day.startOfDay }
    }

    /// The few days right before the next predicted period.
    func calculatePrePeriodTime() {
        guard let nextPeriodStart = periodDates.min() else {
            self.prePeriodDates = []
            return
        }
        self.prePeriodDates = (0..<amountOfPrePeriodDays).compactMap { day in
            Calendar.current.date(byAdding: .day, value: -(day + 1), to: nextPeriodStart)
        }
    }

    /// The next period starts a full cycle after the last logged one started. Nothing
    /// gets predicted until the athlete has logged at least one period.
    func calculatePeriodTimes() {
        guard let lastPeriod = periodDue.lastPeriodStart(in: reviews),
              let startOfPeriodDay = Calendar.current.date(byAdding: .day, value: periodDue.cycleLength, to: lastPeriod.startOfDay)
        else {
            self.periodDates = []
            return
        }

        self.periodDates = calculatePeriodDates(startOfPeriodDay)
    }

    /// Runs after `calculatePeriodTimes()` and keeps adding periods a cycle apart until
    /// there are `amountOfPredictedCycles` of them.
    func calculateNewMonthPeriod() {
        // Nothing to extend from if no period has been predicted yet.
        guard var lastStart = periodDates.min() else { return }
        // Counted with a loop rather than checking `periodBatches()`, because really long
        // periods can merge into one run and it'd never reach the target.
        for _ in 1..<max(amountOfPredictedCycles, 1) {
            guard let startOfNextPeriod = Calendar.current.date(byAdding: .day, value: periodDue.cycleLength, to: lastStart)
            else { return }
            self.periodDates.append(contentsOf: calculatePeriodDates(startOfNextPeriod))
            lastStart = startOfNextPeriod
        }
    }

    /// Builds a run of consecutive period days starting at `startingDate`.
    func calculatePeriodDates(_ startingDate: Date) -> [Date] {
        (0..<amountOfPeriodDays).compactMap { day in
            Calendar.current.date(byAdding: .day, value: day, to: startingDate)
        }
    }

    func isPeriodDay(_ day: Date) -> Bool {
        periodDates.contains { $0.startOfDay == day.startOfDay }
    }

    /// Average length of the user's logged periods, rounded. Nil if none are logged.
    func averageLoggedPeriodLength() -> Int? {
        let runs = Self.consecutiveRuns(of: Array(loggedPeriodDates))
        guard !runs.isEmpty else { return nil }
        let totalDays = runs.reduce(0) { $0 + $1.count }
        return Int((Double(totalDays) / Double(runs.count)).rounded())
    }

    /// Splits `periodDates` into one block per period, which the calendar uses to
    /// round off the first and last day of each pill.
    func periodBatches() -> [[Date]] {
        Self.consecutiveRuns(of: periodDates)
    }

    /// Sorts the dates, drops repeats and starts a new run wherever a day is skipped.
    static func consecutiveRuns(of dates: [Date]) -> [[Date]] {
        var runs: [[Date]] = []
        var currentRun: [Date] = []

        for day in dates.sorted() {
            // Overlapping predictions can repeat a day, which shouldn't start a new run.
            if let last = currentRun.last, Calendar.current.isDate(day, inSameDayAs: last) {
                continue
            }
            if let last = currentRun.last,
               let dayAfterLast = Calendar.current.date(byAdding: .day, value: 1, to: last),
               Calendar.current.isDate(day, inSameDayAs: dayAfterLast) {
                currentRun.append(day)
            } else {
                if !currentRun.isEmpty {
                    runs.append(currentRun)
                }
                currentRun = [day]
            }
        }

        if !currentRun.isEmpty {
            runs.append(currentRun)
        }

        return runs
    }
}

//
//  CalendarViewModel.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import Foundation
import Combine
import SwiftUI

/// Works out the calendar's period highlights from the user's logged reviews:
/// the days they logged a period, plus predicted period and pre-period days.
/// Call `update(with:)` whenever the reviews change.
class CalendarViewModel: ObservableObject {

    @Published var amountOfPrePeriodDays: Int = 3
    /// Length of each predicted period. Set from the average logged period,
    /// and only kept at this default until the user has logged one.
    @Published var amountOfPeriodDays: Int = 6
    /// How many upcoming periods to predict.
    var amountOfPredictedCycles = 2

    /// Shared with the "Period Due" header and the widget, so all three agree on when the next period starts.
    var periodDue = PeriodDueViewModel()

    /// Days the user answered "yes" to being on their period, as `startOfDay`.
    @Published private(set) var loggedPeriodDates: Set<Date> = []
    @Published var prePeriodDates: [Date] = []
    @Published var periodDates: [Date] = []

    /// Kept so the predictions can be rebuilt from the same logs.
    private var reviews: [PollAnswers] = []

    init(reviews: [PollAnswers] = []) {
        update(with: reviews)
    }

    /// Rebuilds logged and predicted days from `reviews`.
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

    /// Pre-period days are the N days immediately before the next predicted period.
    func calculatePrePeriodTime() {
        guard let nextPeriodStart = periodDates.min() else {
            self.prePeriodDates = []
            return
        }
        self.prePeriodDates = (0..<amountOfPrePeriodDays).compactMap { day in
            Calendar.current.date(byAdding: .day, value: -(day + 1), to: nextPeriodStart)
        }
    }

    /// Next period starts a full cycle after the last logged period started.
    /// Nothing is predicted until the user has logged a period.
    func calculatePeriodTimes() {
        guard let lastPeriod = periodDue.lastPeriodStart(in: reviews),
              let startOfPeriodDay = Calendar.current.date(byAdding: .day, value: periodDue.cycleLength, to: lastPeriod.startOfDay)
        else {
            self.periodDates = []
            return
        }

        self.periodDates = calculatePeriodDates(startOfPeriodDay)
    }

    /// After `calculatePeriodTimes()`, adds further predicted periods, each a full cycle
    /// after the previous one started, until there are `amountOfPredictedCycles`.
    func calculateNewMonthPeriod() {
        // Nothing to extend from if no period has been predicted yet.
        guard var lastStart = periodDates.min() else { return }
        // Counted rather than checked via `periodBatches()`, since very long periods
        // can merge into one run and would never reach the target count.
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

    /// Groups `periodDates` into runs of consecutive days, so each cycle
    /// can be treated as its own block (used for first/last-day checks).
    func periodBatches() -> [[Date]] {
        Self.consecutiveRuns(of: periodDates)
    }

    /// Sorts `dates`, drops repeated days, and splits them wherever a day is skipped.
    static func consecutiveRuns(of dates: [Date]) -> [[Date]] {
        var runs: [[Date]] = []
        var currentRun: [Date] = []

        for day in dates.sorted() {
            // Overlapping predictions can repeat a day; it doesn't start a new run.
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

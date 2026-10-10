//
//  PeriodDueViewModel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  All the "when is my next period" maths in one place. The Home header, the
//  cycle ring, the calendar predictions and the widget all go through this so
//  they never disagree with each other.
//

import Foundation

struct PeriodDueViewModel {
    var cycleLength = 28

    /// First day of the most recent period, or nil if they've never logged one.
    func lastPeriodStart(in answers: [PollAnswers]) -> Date? {
        Self.latestPeriodStart(in: answers)
    }

    /// Finds the latest "yes, on my period" day, then walks backwards day by day to
    /// find where that period started. Cycles count from the first day, not the last.
    /// Passing `day` ignores anything logged after it.
    static func latestPeriodStart(in answers: [PollAnswers], onOrBefore day: Date? = nil) -> Date? {
        let limit = day?.startOfDay
        let periodDays = Set(answers
            .filter { $0.answers[.onPeriod] == .yes }
            .map(\.date.startOfDay)
            .filter { periodDay in limit.map { periodDay <= $0 } ?? true })
        guard var start = periodDays.max() else { return nil }
        while let previous = Calendar.current.date(byAdding: .day, value: -1, to: start),
              periodDays.contains(previous) {
            start = previous
        }
        return start
    }

    /// Last period start plus the cycle length, counted in days from today.
    func daysUntilNextPeriod(in answers: [PollAnswers]) -> Int? {
        guard let last = lastPeriodStart(in: answers),
              let next = Calendar.current.date(byAdding: .day, value: cycleLength, to: last)
        else { return nil }
        return Calendar.current.dateComponents([.day], from: Date().startOfDay, to: next).day
    }

    /// Text for the "Period Due" header, covering due today and overdue too.
    func dueText(for answers: [PollAnswers]) -> String {
        guard let days = daysUntilNextPeriod(in: answers) else { return "Not logged" }
        switch days {
        case 0: return "Due today"
        case ..<0: return "Overdue by \(Self.dayCount(-days))"
        default: return Self.dayCount(days)
        }
    }

    /// How much of the cycle is left, from 1 (whole cycle ahead) down to 0 (period due).
    /// The cycle ring uses this as a countdown, so the arc shrinks back towards the droplet.
    func cycleProgress(in answers: [PollAnswers]) -> Double {
        guard let days = daysUntilNextPeriod(in: answers) else { return 0 }
        let remaining = Double(days) / Double(cycleLength)
        return min(max(remaining, 0), 1)
    }

    /// Today's phase, estimated from how many days are left until the next period.
    func phase(in answers: [PollAnswers]) -> String {
        guard let days = daysUntilNextPeriod(in: answers) else { return "Not logged" }
        // Day 1 is the first day of the last period.
        let cycleDay = cycleLength - days + 1
        switch cycleDay {
        case ...5: return "Menstrual Phase"
        case 6...13: return "Follicular Phase"
        case 14...16: return "Ovulation Phase"
        default: return "Luteal Phase"
        }
    }

    private static func dayCount(_ days: Int) -> String {
        days == 1 ? "1 Day" : "\(days) Days"
    }
}

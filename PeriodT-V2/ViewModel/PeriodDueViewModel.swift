//
//  PeriodDueViewModel.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation

/// Works out when the next period is due from the user's logged poll answers.
struct PeriodDueViewModel {
    var cycleLength = 28

    /// Most recent day the user answered "yes" to being on their period.
    func lastReportedPeriod(in answers: [PollAnswers]) -> Date? {
        answers
            .filter { $0.answers[.onPeriod] == .yes }
            .map(\.date)
            .max()
    }

    /// Last period + cycle length, measured in days from today. Nil if never logged.
    func daysUntilNextPeriod(in answers: [PollAnswers]) -> Int? {
        guard let last = lastReportedPeriod(in: answers),
              let next = Calendar.current.date(byAdding: .day, value: cycleLength, to: last)
        else { return nil }
        return Calendar.current.dateComponents([.day], from: Date().startOfDay, to: next).day
    }

    /// Copy for the "Period Due" header, including overdue and due-today cases.
    func dueText(for answers: [PollAnswers]) -> String {
        guard let days = daysUntilNextPeriod(in: answers) else { return "Not logged" }
        switch days {
        case 0: return "Due today"
        case ..<0: return "Overdue by \(Self.dayCount(-days))"
        default: return Self.dayCount(days)
        }
    }

    /// Share of the cycle still to go, 1 (full cycle ahead) down to 0 (period due).
    /// Drives the cycle ring as a countdown: the arc shrinks back towards the droplet.
    func cycleProgress(in answers: [PollAnswers]) -> Double {
        guard let days = daysUntilNextPeriod(in: answers) else { return 0 }
        let remaining = Double(days) / Double(cycleLength)
        return min(max(remaining, 0), 1)
    }

    /// Cycle phase for today, estimated from days left until the next period.
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

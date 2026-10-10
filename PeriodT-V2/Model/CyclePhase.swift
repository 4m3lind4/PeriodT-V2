//
//  CyclePhase.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Foundation

/// The four menstrual cycle phases, worked out from days since the last period started.
enum CyclePhase: String {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulation = "Ovulation"
    case luteal = "Luteal"

    /// Day 1 is the first day of the last logged period.
    init(cycleDay: Int) {
        if cycleDay <= 5 {
            self = .menstrual
        } else if cycleDay <= 13 {
            self = .follicular
        } else if cycleDay <= 16 {
            self = .ovulation
        } else {
            self = .luteal
        }
    }

    /// Notification text for each phase.
    var message: String {
        switch self {
        case .menstrual:  return "You're in your Menstrual Phase 🩸 Rest up and go gentle today."
        case .follicular: return "You're in your Follicular Phase 🌱 Energy is rising, a great time to try something new!"
        case .ovulation:  return "You're in your Ovulation Phase ☀️ You're at peak energy today."
        case .luteal:     return "You're in your Luteal Phase 🌙 Be kind to yourself and slow down."
        }
    }

    /// Works out the current phase from logged reviews. Returns nil if no period has been logged.
    static func current(from answers: [PollAnswers], cycleLength: Int = 28) -> CyclePhase? {
        phase(on: Date(), from: answers, cycleLength: cycleLength)
    }

    /// The phase on `day`, counted from the latest period logged on or before it.
    /// Nil if no period had been logged by then.
    static func phase(on day: Date, from answers: [PollAnswers], cycleLength: Int = 28) -> CyclePhase? {
        let day = day.startOfDay
        guard let last = answers
                .filter({ $0.answers[.onPeriod] == .yes && $0.date <= day })
                .map(\.date)
                .max(),
              let daysSince = Calendar.current.dateComponents([.day], from: last.startOfDay, to: day).day
        else { return nil }
        // Wrap around if the user is past a full cycle without logging.
        let cycleDay = (daysSince % cycleLength) + 1
        return CyclePhase(cycleDay: cycleDay)
    }
}

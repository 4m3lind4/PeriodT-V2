//
//  CyclePhase.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Works out which menstrual phase the athlete is in from their logged periods.
//  This drives the phase notification and the colours on the cycle ring.
//

import Foundation

enum CyclePhase: String {
    case menstrual = "Menstrual"
    case follicular = "Follicular"
    case ovulation = "Ovulation"
    case luteal = "Luteal"

    /// Day 1 is the first day of the last logged period. The day ranges are the usual
    /// textbook split of a 28 day cycle. Every athlete is different, so this is a rough
    /// guide for the app, not something to diagnose with.
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

    /// The phase on `day`, counted from the first day of the latest period logged on or before it.
    /// Nil if no period had been logged by then.
    static func phase(on day: Date, from answers: [PollAnswers], cycleLength: Int = 28) -> CyclePhase? {
        let day = day.startOfDay
        guard let last = PeriodDueViewModel.latestPeriodStart(in: answers, onOrBefore: day),
              let daysSince = Calendar.current.dateComponents([.day], from: last.startOfDay, to: day).day
        else { return nil }
        // If they've gone a full cycle without logging, wrap around rather than
        // getting stuck in luteal forever.
        let cycleDay = (daysSince % cycleLength) + 1
        return CyclePhase(cycleDay: cycleDay)
    }
}

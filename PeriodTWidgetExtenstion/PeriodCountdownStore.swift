//
//  PeriodCountdownStore.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Foundation

/// Shared by the app (writes the last logged period) and the widget extension (reads it),
/// so this file is a member of both targets. Data lives in the shared App Group defaults.
enum PeriodCountdownStore {
    static let appGroup = "group.Jessica.a.m.PeriodT-V2"
    static let widgetKind = "PeriodTWidgetExtension"

    private static let lastPeriodKey = "lastPeriodDate"
    private static let cycleLengthKey = "cycleLength"

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    /// Saves the latest period start. Returns true if anything changed, so callers only
    /// reload the widget when they need to.
    @discardableResult
    static func save(lastPeriod: Date?, cycleLength: Int) -> Bool {
        guard let defaults else { return false }
        let oldPeriod = defaults.object(forKey: lastPeriodKey) as? Date
        let oldCycle = defaults.integer(forKey: cycleLengthKey)
        guard oldPeriod != lastPeriod || oldCycle != cycleLength else { return false }

        defaults.set(lastPeriod, forKey: lastPeriodKey)
        defaults.set(cycleLength, forKey: cycleLengthKey)
        return true
    }

    /// Same maths as `PeriodDueViewModel.daysUntilNextPeriod`. Nil if never logged.
    static func daysUntilNextPeriod(from today: Date = Date()) -> Int? {
        guard let defaults,
              let last = defaults.object(forKey: lastPeriodKey) as? Date
        else { return nil }
        let cycleLength = defaults.integer(forKey: cycleLengthKey)
        let calendar = Calendar.current
        guard cycleLength > 0,
              let next = calendar.date(byAdding: .day, value: cycleLength, to: last)
        else { return nil }
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: today), to: next).day
    }
}

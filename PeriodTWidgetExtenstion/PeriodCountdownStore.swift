//
//  PeriodCountdownStore.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  The bridge between the app and the countdown widget. The widget runs in its
//  own process and can't see Supabase or TrackingStore, so the app writes the
//  last period start into the shared App Group and the widget reads it back.
//  This file is in both targets for that reason.
//

import Foundation

enum PeriodCountdownStore {
    static let appGroup = "group.Jessica.a.m.PeriodT-V2"
    static let widgetKind = "PeriodTWidgetExtension"

    private static let lastPeriodKey = "lastPeriodDate"
    private static let cycleLengthKey = "cycleLength"

    private static var defaults: UserDefaults? { UserDefaults(suiteName: appGroup) }

    /// Saves the latest period start. Returns true if anything actually changed, so the
    /// app only reloads the widget when it needs to (iOS rations widget reloads).
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

    /// Same maths as `PeriodDueViewModel.daysUntilNextPeriod`, copied here because the
    /// extension can't see the app's view models. Nil if nothing's been logged.
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

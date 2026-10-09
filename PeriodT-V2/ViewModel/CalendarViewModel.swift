//
//  CalendarViewModel.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import Foundation
import Combine
import SwiftUI

/// Predicts pre-period and period days for the calendar highlights.
/// Currently uses fixed offsets from today rather than logged data.
class CalendarViewModel: ObservableObject {
    
    @Published var amountOfPrePeriodDays: Int = 3
    @Published var amountOfPeriodDays: Int = 6
    
    @Published var prePeriodDates: [Date] = []
    @Published var periodDates: [Date] = []
    
    init() {
        calculatePrePeriodTime()
        calculatePeriodTimes()
        calculateNewMonthPeriod()
    }
    
    func isPrePeriodDay(_ day: Date) -> Bool {
        return prePeriodDates.contains { $0.startOfDay == day.startOfDay }
    }
    
    /// Pre-period days are the N days immediately before today.
    func calculatePrePeriodTime() {
        let today = Date()
        self.prePeriodDates = (0..<amountOfPrePeriodDays).compactMap { day in
            Calendar.current.date(byAdding: .day, value: -(day + 1), to: today)
        }
    }
    
    /// First predicted period starts 7 days from today.
    func calculatePeriodTimes() {
        let startOfToday = Date().startOfDay
        guard let startOfPeriodDay = Calendar.current.date(byAdding: .day, value: 7, to: startOfToday) else { return }
        
        self.periodDates = calculatePeriodDates(startOfPeriodDay)
    }
    
    /// Adds the following cycle's period, 21 days after the last predicted day.
    func calculateNewMonthPeriod() {
        // Nothing to extend from if no period has been predicted yet.
        guard let lastPeriodDay = periodDates.max(),
              let startOfNextPeriod = Calendar.current.date(byAdding: .day, value: 21, to: lastPeriodDay)
        else { return }
        
        self.periodDates.append(contentsOf: calculatePeriodDates(startOfNextPeriod))
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
    
    /// Groups `periodDates` into runs of consecutive days, so each cycle
    /// can be treated as its own block (used for first/last-day checks).
    func periodBatches() -> [[Date]] {
        let sortedPeriodBatches = periodDates.sorted()
        var periodBatches: [[Date]] = []
        var currentBatch: [Date] = []
        
        for day in sortedPeriodBatches {
            if let last = currentBatch.last,
               let dayAfterLast = Calendar.current.date(byAdding: .day, value: 1, to: last),
               Calendar.current.isDate(day, inSameDayAs: dayAfterLast) {
                currentBatch.append(day)
            } else {
                if !currentBatch.isEmpty {
                    periodBatches.append(currentBatch)
                }
                currentBatch = [day]
            }
        }
        
        if !currentBatch.isEmpty {
            periodBatches.append(currentBatch)
        }
        
        return periodBatches
    }
}

//
//  WeekSelectorViewModel.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation

/// Supplies the current week's days (Monday–Sunday) for the home week strip.
struct WeekSelectorViewModel {
    let currentDate = Date()
    
    private let fullMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // "MMMM" outputs the full name (e.g., September)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var currentMonthName: String {
        fullMonthFormatter.string(from: currentDate)
    }
    
    private let programDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var currentDateAbrev: String {
        programDateFormatter.string(from: currentDate).uppercased()
    }
    
    var currentDateNumber: Int {
        Calendar.current.component(.day, from: currentDate)
    }
    
    /// How many days today is past Monday (Mon = 0 ... Sun = 6).
    private var dateOffSet: Int {
        switch currentDateAbrev {
        case "MON": return 0
        case "TUE": return 1
        case "WED": return 2
        case "THU": return 3
        case "FRI": return 4
        case "SAT": return 5
        case "SUN": return 6
        default: return 0
        }
    }
    
    private var startOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: -dateOffSet, to: currentDate) ?? currentDate
    }

    /// The seven days of the current week, starting from Monday.
    var days: [WeekDayItem] {
        (0..<7).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: offset, to: startOfWeek) ?? startOfWeek
            return WeekDayItem(
                day: programDateFormatter.string(from: date).uppercased(),
                date: Calendar.current.component(.day, from: date)
            )
        }
    }
}

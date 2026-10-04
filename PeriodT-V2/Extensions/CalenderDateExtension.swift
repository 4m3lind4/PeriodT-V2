//
//  CalenderDateExtension.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//


//
//  DateFormatter.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//
import Foundation

/// Date helpers used to build the calendar grid.
extension Date {
    
    /// Single-letter weekday headers, Monday first ("M", "T", "W" ...).
    static var capitaliseFirstLetterOfWeek : [String] {
        let calendar = Calendar.current
        // shortWeekdaySymbols is always Sunday-first; rotate so Monday leads.
        let weekdays = Array(calendar.shortWeekdaySymbols.dropFirst())
            + [calendar.shortWeekdaySymbols[0]]
        
        return weekdays.map { weekday in

            guard let firstLetter = weekday.first else { return "" }
                return String(firstLetter).capitalized
        }
    }
    
    static var fullMonthNames: [String] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        return (1...12).compactMap { month in
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: 1)) //Create a date with the given month name
            
            return date.map {dateFormatter.string(from: $0)}
        }
    }
    
    // `Calendar` returns optionals for every arithmetic call; these fall back to
    // `self` rather than crashing, which at worst mis-lays-out one month.
    var StartOfMonth: Date {
        Calendar.current.dateInterval(of: .month, for: self)?.start ?? startOfDay
    }
    
    var EndOfMonth: Date {
        guard let interval = Calendar.current.dateInterval(of: .month, for: self),
              let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: interval.end)
        else { return startOfDay }
        return lastDay
    }
    
    var startOfPreviousMonth: Date {
        let dayInPreviousMonth = Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
        return dayInPreviousMonth.StartOfMonth
    }
    
    var numberOfDaysInMonth: Int {
        Calendar.current.component(.day, from: EndOfMonth)
    }
    
    /// The Monday on or before the 1st of the month (grid is Monday-first).
    var mondayBeforeStart: Date {
        let startOfMonthWeekday = Calendar.current.component(.weekday, from: StartOfMonth) // 1 = Sun ... 7 = Sat
        let daysSinceMonday = (startOfMonthWeekday + 5) % 7
        return Calendar.current.date(byAdding: .day, value: -daysSinceMonday, to: StartOfMonth) ?? StartOfMonth
    }
    
    /// Every day to show for this month's grid: the month itself plus the
    /// trailing days of the previous month needed to pad the first row to Monday.
    var calendarDisplayDays: [Date] {
        
        let thisMonth = (0..<numberOfDaysInMonth).compactMap { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: StartOfMonth)
        }
        let previousMonth = (0..<startOfPreviousMonth.numberOfDaysInMonth).compactMap { dayOffset in
            Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfPreviousMonth)
        }
        let days = thisMonth + previousMonth
                
        return days.filter { $0 >= mondayBeforeStart && $0 <= EndOfMonth }.sorted(by: <)
    }
    
    var monthInt: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self) ?? self
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// First column of the calendar grid. The grid is always laid out
    /// Monday-first (see `calendarDisplayDays`), regardless of locale.
    var isFirstDayOfRow: Bool {
        Calendar.current.component(.weekday, from: self) == 2 // Monday
    }

    /// Last column of the calendar grid (Sunday).
    var isLastDayOfRow: Bool {
        Calendar.current.component(.weekday, from: self) == 1 // Sunday
    }
}

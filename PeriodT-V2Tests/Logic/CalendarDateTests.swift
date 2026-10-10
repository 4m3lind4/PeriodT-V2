//
//  CalendarDateTests.swift
//  PeriodT-V2Tests
//
//  Tests the Date helpers behind the Monday-first month grid.
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("Date calendar-grid helpers")
struct CalendarDateTests {
    private let calendar = Calendar.current

    // MARK: - Month bounds

    @Test func startAndEndOfMonth() {
        let mid = TestDates.date(2026, 10, 17)
        #expect(mid.StartOfMonth == TestDates.date(2026, 10, 1).startOfDay)
        #expect(calendar.isDate(mid.EndOfMonth, inSameDayAs: TestDates.date(2026, 10, 31)))
    }

    @Test(arguments: [
        (2026, 1, 31), (2026, 2, 28), (2028, 2, 29), (2100, 2, 28),
        (2026, 4, 30), (2026, 12, 31)
    ])
    func numberOfDaysInMonth(year: Int, month: Int, days: Int) {
        #expect(TestDates.date(year, month, 10).numberOfDaysInMonth == days)
    }

    @Test func startOfPreviousMonthCrossesYear() {
        #expect(TestDates.date(2026, 1, 15).startOfPreviousMonth == TestDates.date(2025, 12, 1).startOfDay)
    }

    @Test func nextMonthClampsToShorterMonth() {
        let next = TestDates.date(2026, 1, 31).nextMonth
        #expect(calendar.isDate(next, inSameDayAs: TestDates.date(2026, 2, 28)))
    }

    @Test func monthInt() {
        #expect(TestDates.date(2026, 10, 1).monthInt == 10)
    }

    @Test func startOfDayDropsTime() {
        let date = TestDates.date(2026, 10, 7, hour: 18)
        #expect(calendar.dateComponents([.hour, .minute], from: date.startOfDay) == DateComponents(hour: 0, minute: 0))
    }

    // MARK: - Monday-first grid

    @Test(arguments: [
        // (month, expected Monday, leading days from previous month)
        (TestDates.date(2026, 10, 20), TestDates.date(2026, 9, 28), 3), // starts Thursday
        (TestDates.date(2026, 2, 10), TestDates.date(2026, 1, 26), 6),  // starts Sunday
        (TestDates.date(2026, 6, 10), TestDates.date(2026, 6, 1), 0)    // starts Monday
    ])
    func gridStartsOnMondayBeforeTheFirst(month: Date, monday: Date, leading: Int) {
        #expect(calendar.isDate(month.mondayBeforeStart, inSameDayAs: monday))
        #expect(month.mondayBeforeStart.isFirstDayOfRow)

        let days = month.calendarDisplayDays
        #expect(days.count == leading + month.numberOfDaysInMonth)
        #expect(calendar.isDate(days[0], inSameDayAs: monday))
        #expect(days.filter { $0.monthInt != month.monthInt }.count == leading)
    }

    @Test(arguments: (1...12).map { TestDates.date(2026, $0, 15) })
    func gridIsSortedContiguousAndEndsOnLastDay(month: Date) throws {
        let days = month.calendarDisplayDays
        for (previous, next) in zip(days, days.dropFirst()) {
            #expect(calendar.dateComponents([.day], from: previous, to: next).day == 1)
        }
        let last = try #require(days.last)
        #expect(calendar.isDate(last, inSameDayAs: month.EndOfMonth))
        #expect(days.first?.isFirstDayOfRow == true)
    }

    @Test func firstAndLastDayOfRow() {
        // 5 Oct 2026 is a Monday, 11 Oct a Sunday.
        #expect(TestDates.date(2026, 10, 5).isFirstDayOfRow)
        #expect(!TestDates.date(2026, 10, 5).isLastDayOfRow)
        #expect(TestDates.date(2026, 10, 11).isLastDayOfRow)
        #expect(!TestDates.date(2026, 10, 8).isFirstDayOfRow)
        #expect(!TestDates.date(2026, 10, 8).isLastDayOfRow)
    }

    // MARK: - Labels

    @Test func weekdayHeadersAreSevenMondayFirstLetters() {
        let headers = Date.capitaliseFirstLetterOfWeek
        #expect(headers.count == 7)
        #expect(headers.allSatisfy { $0.count == 1 })
        let monday = calendar.shortWeekdaySymbols[1].prefix(1).capitalized
        let sunday = calendar.shortWeekdaySymbols[0].prefix(1).capitalized
        #expect(headers.first == monday)
        #expect(headers.last == sunday)
    }

    @Test func fullMonthNames() {
        let names = Date.fullMonthNames
        #expect(names.count == 12)
        #expect(Set(names).count == 12)
    }

    @Test(arguments: [
        (TestDates.date(2026, 9, 14), "MON 14 SEP"),
        (TestDates.date(2026, 1, 1), "THU 1 JAN"),
        (TestDates.date(2026, 12, 31), "THU 31 DEC")
    ])
    func formattedProgramDate(date: Date, expected: String) {
        #expect(date.formattedProgramDate() == expected)
    }

    // MARK: - Calendar cell identifiers (used by UI tests)

    @Test func calendarDayIdentifierIsZeroPadded() {
        #expect(CalendarView.dayIdentifier(for: TestDates.date(2026, 3, 7)) == "calendar-day-2026-03-07")
        #expect(CalendarView.dayIdentifier(for: TestDates.date(2026, 12, 25, hour: 23)) == "calendar-day-2026-12-25")
    }
}

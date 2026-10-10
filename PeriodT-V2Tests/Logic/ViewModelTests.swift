//
//  ViewModelTests.swift
//  PeriodT-V2Tests
//
//  CalendarViewModel, WeekSelectorViewModel and AppNavigationViewModel.
//

import Foundation
import SwiftUI
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("CalendarViewModel")
struct CalendarViewModelTests {
    private let viewModel = CalendarViewModel()

    @Test func prePeriodIsTheThreeDaysBeforeToday() {
        #expect(viewModel.prePeriodDates.count == 3)
        #expect(viewModel.isPrePeriodDay(TestDates.daysFromToday(-1)))
        #expect(viewModel.isPrePeriodDay(TestDates.daysFromToday(-3)))
        #expect(!viewModel.isPrePeriodDay(TestDates.daysFromToday(-4)))
        #expect(!viewModel.isPrePeriodDay(Date()))
    }

    @Test func predictsTwoSixDayPeriods() {
        #expect(viewModel.periodDates.count == 12)
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(6)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(7)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(12)))
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(13)))
        // Next cycle starts 21 days after the last predicted day (+12).
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(32)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(33)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(38)))
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(39)))
    }

    @Test func isPeriodDayIgnoresTimeOfDay() {
        let evening = TestDates.daysFromToday(7).addingTimeInterval(22 * 3600)
        #expect(viewModel.isPeriodDay(evening))
    }

    @Test func periodBatchesGroupConsecutiveDays() {
        let batches = viewModel.periodBatches()
        #expect(batches.map(\.count) == [6, 6])
    }

    @Test func periodBatchesSplitOnGapsAndSort() {
        let viewModel = CalendarViewModel()
        viewModel.periodDates = [
            TestDates.date(2026, 3, 5), TestDates.date(2026, 3, 1),
            TestDates.date(2026, 3, 2), TestDates.date(2026, 3, 9)
        ]
        let batches = viewModel.periodBatches()
        #expect(batches.map(\.count) == [2, 1, 1])
        #expect(batches.first?.first == TestDates.date(2026, 3, 1))
    }

    @Test func periodBatchesEmpty() {
        let viewModel = CalendarViewModel()
        viewModel.periodDates = []
        #expect(viewModel.periodBatches().isEmpty)
        // Nothing to extend from, so no new cycle is added.
        viewModel.calculateNewMonthPeriod()
        #expect(viewModel.periodDates.isEmpty)
    }

    @Test func amountOfPeriodDaysDrivesRunLength() {
        let viewModel = CalendarViewModel()
        viewModel.amountOfPeriodDays = 4
        #expect(viewModel.calculatePeriodDates(TestDates.date(2026, 3, 1)).count == 4)
    }
}

@MainActor
@Suite("WeekSelectorViewModel")
struct WeekSelectorViewModelTests {
    private let viewModel = WeekSelectorViewModel()

    @Test func weekRunsMondayToSunday() {
        #expect(viewModel.days.map(\.day) == ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"])
    }

    @Test func weekContainsToday() {
        let today = Calendar.current.component(.day, from: Date())
        #expect(viewModel.currentDateNumber == today)
        #expect(viewModel.days.filter { $0.date == today }.count == 1)
    }

    @Test func todayIsInTheRightColumn() throws {
        let index = try #require(viewModel.days.firstIndex { $0.date == viewModel.currentDateNumber })
        #expect(viewModel.days[index].day == viewModel.currentDateAbrev)
    }

    @Test func monthNameIsEnglishFullName() {
        let expected = Date().formatted(Date.FormatStyle(locale: Locale(identifier: "en_US_POSIX")).month(.wide))
        #expect(viewModel.currentMonthName == expected)
    }
}

@MainActor
@Suite("AppNavigationViewModel")
struct AppNavigationViewModelTests {

    @Test func startsOnHomeWithEmptyExerciseStack() {
        let navigation = AppNavigationViewModel()
        #expect(navigation.selectedTab == .home)
        #expect(navigation.exercisePath.isEmpty)
    }

    @Test func returnHomeClearsStackAndSwitchesTab() {
        let navigation = AppNavigationViewModel()
        navigation.selectedTab = .exercise
        let program = Fixtures.program(on: .now)
        navigation.exercisePath.append(program)
        navigation.exercisePath.append(ExerciseFlow.completed(program))
        #expect(navigation.exercisePath.count == 2)

        navigation.returnHome()

        #expect(navigation.selectedTab == .home)
        #expect(navigation.exercisePath.isEmpty)
    }

    @Test func tabsAreInTabBarOrder() {
        #expect(AppNavigationViewModel.Tab.home.rawValue == 0)
        #expect(AppNavigationViewModel.Tab.calendar.rawValue == 1)
        #expect(AppNavigationViewModel.Tab.exercise.rawValue == 2)
        #expect(AppNavigationViewModel.Tab.journal.rawValue == 3)
    }
}

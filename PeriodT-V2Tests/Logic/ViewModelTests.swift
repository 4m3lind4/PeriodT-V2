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
    /// A five-day period logged from 10 to 6 days ago, plus an unrelated non-period review.
    private let reviews = (6...10).map { Fixtures.period(daysAgo: $0) }
        + [Fixtures.review(on: TestDates.daysFromToday(-2), onPeriod: .no)]

    private var viewModel: CalendarViewModel { CalendarViewModel(reviews: reviews) }

    @Test func nothingLoggedMeansNothingPredicted() {
        let viewModel = CalendarViewModel()
        #expect(viewModel.loggedPeriodDates.isEmpty)
        #expect(viewModel.periodDates.isEmpty)
        #expect(viewModel.prePeriodDates.isEmpty)
        #expect(viewModel.amountOfPeriodDays == 6)
    }

    @Test func loggedPeriodDaysComeFromYesAnswers() {
        let viewModel = viewModel
        #expect(viewModel.loggedPeriodDates.count == 5)
        #expect(viewModel.isLoggedPeriodDay(TestDates.daysFromToday(-6)))
        #expect(viewModel.isLoggedPeriodDay(TestDates.daysFromToday(-10)))
        #expect(!viewModel.isLoggedPeriodDay(TestDates.daysFromToday(-5)))
        #expect(!viewModel.isLoggedPeriodDay(TestDates.daysFromToday(-2)))
    }

    @Test func predictedLengthIsTheAverageLoggedPeriod() {
        // Runs of 5 and 2 days average to 3.5, which rounds to 4.
        let viewModel = CalendarViewModel(reviews: reviews + [Fixtures.period(daysAgo: 40),
                                                              Fixtures.period(daysAgo: 41)])
        #expect(viewModel.amountOfPeriodDays == 4)
    }

    @Test func predictsTwoPeriodsACycleApart() {
        let viewModel = viewModel
        // The logged period started at -10, so the next one starts 28 days later at +18.
        #expect(viewModel.periodBatches().map(\.count) == [5, 5])
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(17)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(18)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(22)))
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(23)))
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(45)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(46)))
        #expect(viewModel.isPeriodDay(TestDates.daysFromToday(50)))
        #expect(!viewModel.isPeriodDay(TestDates.daysFromToday(51)))
    }

    @Test func prePeriodIsTheThreeDaysBeforeTheNextPeriod() {
        let viewModel = viewModel
        #expect(viewModel.prePeriodDates.count == 3)
        #expect(viewModel.isPrePeriodDay(TestDates.daysFromToday(17)))
        #expect(viewModel.isPrePeriodDay(TestDates.daysFromToday(15)))
        #expect(!viewModel.isPrePeriodDay(TestDates.daysFromToday(14)))
        #expect(!viewModel.isPrePeriodDay(TestDates.daysFromToday(18)))
    }

    @Test func updateReplacesEarlierData() {
        let viewModel = viewModel
        viewModel.update(with: [])
        #expect(viewModel.loggedPeriodDates.isEmpty)
        #expect(viewModel.periodDates.isEmpty)
        #expect(viewModel.prePeriodDates.isEmpty)
    }

    @Test func periodsAsLongAsTheCycleStillFinish() {
        // Logging every day for 30 days makes predicted periods overlap into one run.
        let viewModel = CalendarViewModel(reviews: (1...30).map { Fixtures.period(daysAgo: $0) })
        #expect(viewModel.periodBatches().count == 1)
    }

    @Test func isPeriodDayIgnoresTimeOfDay() {
        let evening = TestDates.daysFromToday(18).addingTimeInterval(22 * 3600)
        #expect(viewModel.isPeriodDay(evening))
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

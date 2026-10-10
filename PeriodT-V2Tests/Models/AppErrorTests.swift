//
//  AppErrorTests.swift
//  PeriodT-V2Tests
//
//  Checks the wording on each error card.
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("AppError copy")
struct AppErrorTests {

    @Test func futureDayTitleNamesTheDay() {
        let day = TestDates.date(2026, 10, 14)
        let title = AppError.futureDay(day).title
        #expect(title.contains(day.formatted(.dateTime.weekday(.wide))))
        #expect(title.contains("14"))
    }

    @Test func futureDayMessage() {
        #expect(AppError.futureDay(.now).message.contains("not available yet"))
    }

    @Test(arguments: [
        (AppError.SaveTarget.pollAnswer, "your answer"),
        (.journal, "your journal"),
        (.workout, "your workout")
    ])
    func saveFailedMessageNamesTarget(target: AppError.SaveTarget, phrase: String) {
        let error = AppError.saveFailed(target)
        #expect(error.title == "Couldn't save")
        #expect(error.message == "Something went wrong saving \(phrase). Please try again.")
    }

    @Test func dataUnavailableCopy() {
        #expect(AppError.dataUnavailable.title == "Your data couldn't be loaded")
        #expect(AppError.dataUnavailable.message.contains("won't be kept"))
    }

    @Test func transientErrorsAutoDismiss() {
        #expect(AppError.futureDay(.now).autoDismisses)
        #expect(AppError.saveFailed(.journal).autoDismisses)
    }

    @Test func dataUnavailableStaysUntilDismissed() {
        #expect(!AppError.dataUnavailable.autoDismisses)
    }

    @Test func errorsAreHashableByValue() {
        let day = TestDates.date(2026, 10, 14)
        #expect(AppError.futureDay(day) == AppError.futureDay(day))
        #expect(AppError.saveFailed(.journal) != AppError.saveFailed(.workout))
        #expect(Set([AppError.dataUnavailable, .dataUnavailable]).count == 1)
    }
}

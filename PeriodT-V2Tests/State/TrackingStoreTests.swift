//
//  TrackingStoreTests.swift
//  PeriodT-V2Tests
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("TrackingStore")
struct TrackingStoreTests {
    private let today = Date().startOfDay
    private let yesterday = TestDates.daysFromToday(-1)

    private func makeStore(_ repository: SpyRepository, saveDelay: Duration = .milliseconds(20)) -> TrackingStore {
        TrackingStore(repository: repository, saveDelay: saveDelay)
    }

    // MARK: - Loading

    @Test func startsEmpty() {
        let store = makeStore(SpyRepository())
        #expect(store.allReviews.isEmpty)
        #expect(store.programs.isEmpty)
        #expect(store.completedProgramDays.isEmpty)
        #expect(store.review(for: today) == nil)
    }

    @Test func loadFillsReviewsKeyedByDay() async {
        let review = Fixtures.review(on: yesterday, onPeriod: .yes, journal: "Cramps")
        let store = makeStore(SpyRepository(reviews: [review]))

        await store.load()

        #expect(store.allReviews == [review])
        // Lookup ignores the time of day.
        #expect(store.review(for: yesterday.addingTimeInterval(15 * 3600)) == review)
        #expect(store.review(for: today) == nil)
    }

    @Test func loadKeepsFirstOfDuplicateDays() async {
        let first = Fixtures.review(on: today, journal: "first")
        let second = Fixtures.review(on: today, journal: "second")
        let store = makeStore(SpyRepository(reviews: [first, second]))

        await store.load()

        #expect(store.allReviews.count == 1)
        #expect(store.review(for: today)?.journal == "first")
    }

    @Test func completedProgramDaysOnlyIncludeProgramsWithATickedWorkout() async {
        let done = Fixtures.program(on: yesterday.addingTimeInterval(9 * 3600),
                                    workouts: [Workout(name: "Plank", isCompleted: true), Workout(name: "Walking")])
        let untouched = Fixtures.program(on: today.addingTimeInterval(9 * 3600),
                                         workouts: [Workout(name: "Plank")])
        let store = makeStore(SpyRepository(programs: [done, untouched]))

        await store.load()

        #expect(store.completedProgramDays == [yesterday])
        #expect(store.programs.count == 2)
    }

    @Test func programsOnDayMatchesCalendarDay() async {
        let morning = Fixtures.program(on: today.addingTimeInterval(8 * 3600), day: 1)
        let evening = Fixtures.program(on: today.addingTimeInterval(19 * 3600), day: 2)
        let other = Fixtures.program(on: yesterday, day: 3)
        let store = makeStore(SpyRepository(programs: [morning, evening, other]))

        await store.load()

        #expect(store.programs(on: today).map(\.day) == [1, 2])
        #expect(store.programs(on: yesterday).map(\.day) == [3])
        #expect(store.programs(on: TestDates.daysFromToday(5)).isEmpty)
    }

    @Test func failedLoadKeepsPreviousValues() async {
        let repository = SpyRepository(programs: [Fixtures.program(on: today)],
                                       reviews: [Fixtures.period(daysAgo: 1)])
        let store = makeStore(repository)
        await store.load()

        repository.failReads = true
        repository.reviews = []
        repository.programs = []
        await store.load()

        #expect(store.allReviews.count == 1)
        #expect(store.programs.count == 1)
    }

    // MARK: - Updating

    @Test func updateAppliesLocallyStraightAway() {
        let store = makeStore(SpyRepository(), saveDelay: .seconds(10))

        store.update(today, onFailure: {}) { $0.setAnswer(.yes, for: .onPeriod) }

        #expect(store.review(for: today)?.answers[.onPeriod] == .yes)
    }

    @Test func updateCreatesReviewForNewDayAndKeepsExistingFields() async {
        let repository = SpyRepository(reviews: [Fixtures.review(on: yesterday, emotion: .calm)])
        let store = makeStore(repository, saveDelay: .seconds(10))
        await store.load()

        store.update(yesterday, onFailure: {}) { $0.journal = "Edited" }

        let review = store.review(for: yesterday)
        #expect(review?.emotion == .calm)
        #expect(review?.journal == "Edited")
    }

    @Test func rapidEditsAreDebouncedIntoOneSaveOfTheLatestValue() async {
        let repository = SpyRepository()
        let store = makeStore(repository, saveDelay: .milliseconds(100))

        for text in ["H", "He", "Hel", "Hello"] {
            store.update(today, onFailure: {}) { $0.journal = text }
        }

        #expect(await waitUntil { repository.savedReviews.count == 1 })
        // Give any stray extra saves time to land.
        try? await Task.sleep(for: .milliseconds(200))
        #expect(repository.savedReviews.count == 1)
        #expect(repository.savedReviews.first?.journal == "Hello")
    }

    @Test func editsOnDifferentDaysSaveIndependently() async {
        let repository = SpyRepository()
        let store = makeStore(repository)

        store.update(today, onFailure: {}) { $0.emotion = .happy }
        store.update(yesterday, onFailure: {}) { $0.emotion = .sad }

        #expect(await waitUntil { repository.savedReviews.count == 2 })
        #expect(Set(repository.savedReviews.map(\.date)) == [today, yesterday])
    }

    @Test func failedSaveCallsOnFailureButKeepsLocalEdit() async {
        let repository = SpyRepository()
        repository.failWrites = true
        let store = makeStore(repository)
        var failures = 0

        store.update(today, onFailure: { failures += 1 }) { $0.intensity = 4 }

        #expect(await waitUntil { failures == 1 })
        #expect(store.review(for: today)?.intensity == 4)
    }

    @Test func successfulSaveDoesNotCallOnFailure() async {
        let repository = SpyRepository()
        let store = makeStore(repository)
        var failures = 0

        store.update(today, onFailure: { failures += 1 }) { $0.intensity = 1 }

        #expect(await waitUntil { repository.savedReviews.count == 1 })
        #expect(failures == 0)
    }

    /// Switching tabs calls `load()`. If that happens inside the save delay, the
    /// refetch replaces the local edit with the server's older copy, so the edit
    /// vanishes from the UI until the next reload.
    @Test func reloadDuringPendingSaveKeepsLocalEdit() async {
        let repository = SpyRepository()
        let store = makeStore(repository, saveDelay: .milliseconds(300))

        store.update(today, onFailure: {}) { $0.setAnswer(.yes, for: .onPeriod) }
        await store.load()

        withKnownIssue("TrackingStore.load() overwrites edits that haven't been saved yet") {
            #expect(store.review(for: today)?.answers[.onPeriod] == .yes)
        }
    }
}

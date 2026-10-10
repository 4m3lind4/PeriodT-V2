//
//  TestSupport.swift
//  PeriodT-V2Tests
//
//  Shared builders and a spy repository for the unit tests.
//

import Foundation
@testable import PeriodT_V2

// MARK: - Dates

enum TestDates {
    /// A fixed local date at noon, so tests don't depend on the time they run.
    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// Start of today shifted by `offset` days.
    static func daysFromToday(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Date().startOfDay)!
    }

    static func adding(days: Int, to date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: date)!
    }
}

// MARK: - Builders

@MainActor
enum Fixtures {
    static func review(on day: Date,
                       onPeriod: ReviewAnswer? = nil,
                       trained: ReviewAnswer? = nil,
                       emotion: Emotion? = nil,
                       intensity: Int? = nil,
                       journal: String = "") -> PollAnswers {
        var review = PollAnswers(date: day)
        if let onPeriod { review.setAnswer(onPeriod, for: .onPeriod) }
        if let trained { review.setAnswer(trained, for: .trained) }
        review.emotion = emotion
        review.intensity = intensity
        review.journal = journal
        return review
    }

    /// A review with a logged period `daysAgo` days before today.
    static func period(daysAgo: Int) -> PollAnswers {
        review(on: TestDates.daysFromToday(-daysAgo), onPeriod: .yes)
    }

    static func program(on date: Date,
                        day: Int = 1,
                        type: ExerciseType = .physio,
                        workouts: [Workout] = [Workout(name: "Plank", sets: 3)]) -> ExerciseProgram {
        ExerciseProgram(date: date,
                        day: day,
                        exerciseDuration: 30,
                        numberOfExercises: workouts.count,
                        exerciseType: type,
                        workouts: workouts)
    }
}

// MARK: - Spy repository

struct TestError: Error {}

/// Records every call and can be told to fail reads or writes independently.
@MainActor
final class SpyRepository: IPeriodTRepository {
    var programs: [ExerciseProgram]
    var reviews: [PollAnswers]
    var failReads = false
    var failWrites = false

    private(set) var savedReviews: [PollAnswers] = []
    private(set) var addedPrograms: [ExerciseProgram] = []
    private(set) var savedCompletions: [(ids: Set<Workout.ID>, program: ExerciseProgram)] = []

    init(programs: [ExerciseProgram] = [], reviews: [PollAnswers] = []) {
        self.programs = programs
        self.reviews = reviews
    }

    func fetchWorkouts() async throws -> [ExerciseProgram] {
        if failReads { throw TestError() }
        return programs
    }

    func addProgram(_ program: ExerciseProgram) async throws {
        if failWrites { throw TestError() }
        addedPrograms.append(program)
    }

    func saveCompletedWorkouts(_ completedIDs: Set<Workout.ID>, in program: ExerciseProgram) async throws {
        if failWrites { throw TestError() }
        savedCompletions.append((completedIDs, program))
    }

    func fetchPollAnswers() async throws -> [PollAnswers] {
        if failReads { throw TestError() }
        return reviews
    }

    func savePollAnswers(_ answers: PollAnswers) async throws {
        if failWrites { throw TestError() }
        savedReviews.append(answers)
    }
}

// MARK: - Async waiting

/// Polls `condition` until it is true or `timeout` passes. Returns the final result.
@MainActor
func waitUntil(timeout: Duration = .seconds(2), _ condition: () -> Bool) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now + timeout
    while clock.now < deadline {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

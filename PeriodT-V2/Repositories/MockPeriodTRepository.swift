//
//  MockPeriodTRepository.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//
//  An in-memory stand-in for Supabase. Used by SwiftUI previews, the unit tests
//  and the UI tests (launched with `-UITesting`), so none of them need a network.
//

import Foundation

/// Anything added is kept in memory until the app quits.
final class MockPeriodTRepository: IPeriodTRepository {

    private var programs: [ExerciseProgram]
    private var pollAnswers: [Date: PollAnswers]
    private let delay: Duration
    private let shouldFail: Bool

    /// - Parameters:
    ///   - programs: Starting data. Defaults to `samplePrograms`.
    ///   - pollAnswers: Starting daily reviews. Defaults to `samplePollAnswers`.
    ///   - delay: Fake network wait, handy for seeing loading states.
    ///   - shouldFail: Throw from every call, handy for previewing error states.
    init(programs: [ExerciseProgram] = MockPeriodTRepository.samplePrograms,
         pollAnswers: [PollAnswers] = MockPeriodTRepository.samplePollAnswers,
         delay: Duration = .zero,
         shouldFail: Bool = false) {
        self.programs = programs
        self.pollAnswers = Dictionary(pollAnswers.map { ($0.date, $0) }, uniquingKeysWith: { _, last in last })
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func fetchWorkouts() async throws -> [ExerciseProgram] {
        try await simulateNetwork()
        return programs.sorted { $0.date < $1.date }
    }

    /// Adding the same program twice (e.g. a retry) keeps one copy, same as the real repository.
    func addProgram(_ program: ExerciseProgram) async throws {
        try await simulateNetwork()
        guard !programs.contains(where: { $0.id == program.id }) else { return }
        programs.append(program)
    }

    func saveCompletedWorkouts(_ completedIDs: Set<Workout.ID>, in program: ExerciseProgram) async throws {
        try await simulateNetwork()
        guard let index = programs.firstIndex(where: { $0.id == program.id }) else { return }
        let updated = programs[index].workouts.map { workout in
            var workout = workout
            workout.isCompleted = completedIDs.contains(workout.id)
            return workout
        }
        let old = programs[index]
        programs[index] = ExerciseProgram(id: old.id,
                                          date: old.date,
                                          day: old.day,
                                          exerciseDuration: old.exerciseDuration,
                                          numberOfExercises: old.numberOfExercises,
                                          exerciseType: old.exerciseType,
                                          workouts: updated)
    }

    func fetchPollAnswers() async throws -> [PollAnswers] {
        try await simulateNetwork()
        return Array(pollAnswers.values)
    }

    func savePollAnswers(_ answers: PollAnswers) async throws {
        try await simulateNetwork()
        pollAnswers[answers.date] = answers
    }

    private func simulateNetwork() async throws {
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        if shouldFail {
            throw URLError(.notConnectedToInternet)
        }
    }
}

// MARK: - Sample Data

extension MockPeriodTRepository {
    /// Dates are relative to today so there's always a mix of past and upcoming programs.
    /// The workout names match `ExerciseImages.csv` so the thumbnails show up.
    static let samplePrograms: [ExerciseProgram] = [
        sampleProgram(daysFromToday: -5, day: 0, duration: 35, type: .conditioningTraining, workouts: [
            ("Goblet Squat", 3),
            ("Push-up", 3),
            ("Walking", nil)
        ]),
        sampleProgram(daysFromToday: -3, day: 1, duration: 30, type: .physio, workouts: [
            ("Glute Bridge", 3),
            ("Bird Dog", 3),
            ("Plank", nil)
        ]),
        sampleProgram(daysFromToday: -1, day: 2, duration: 45, type: .conditioningTraining, workouts: [
            ("Goblet Squat", 4),
            ("Kettlebell Swing", 3),
            ("Rowing Machine", nil)
        ]),
        sampleProgram(daysFromToday: 0, day: 3, duration: 40, type: .physio, workouts: [
            ("Hip Thrust", 3),
            ("Side Planks", 2),
            ("Dumbbell Lunges", 3),
            ("Russian Twist", 3)
        ]),
        sampleProgram(daysFromToday: 2, day: 4, duration: 50, type: .conditioningTraining, workouts: [
            ("Romanian Deadlift", 4),
            ("Dumbbell Row", 3),
            ("Push-up", 3),
            ("Jump Rope", nil)
        ]),
        sampleProgram(daysFromToday: 5, day: 5, duration: 25, type: .physio, workouts: [
            ("Pallof Press", 3),
            ("Step-Up", 3),
            ("Walking", nil)
        ]),
        sampleProgram(daysFromToday: 7, day: 6, duration: 45, type: .conditioningTraining, workouts: [
            ("Kettlebell Swing", 3),
            ("Dumbbell Row", 3),
            ("Plank", nil)
        ])
    ]

    /// A period logged from 5 to 2 days ago plus a few normal days, so the calendar shows
    /// a joined-up pill. "Period Due" counts from the first day, so it should read 23 Days.
    static let samplePollAnswers: [PollAnswers] = [
        sampleReview(daysFromToday: -6, trained: .yes, onPeriod: .no, emotion: .happy, intensity: 4,
                     journal: "Felt strong on the squats today."),
        sampleReview(daysFromToday: -5, trained: .no, onPeriod: .yes, emotion: .sad, intensity: 1,
                     journal: "Cramps all morning, skipped training."),
        sampleReview(daysFromToday: -4, trained: .yes, onPeriod: .yes, emotion: .neutral, intensity: 2,
                     journal: "Light physio session, went okay."),
        sampleReview(daysFromToday: -3, trained: .no, onPeriod: .yes, emotion: .stressed, intensity: 1,
                     journal: ""),
        sampleReview(daysFromToday: -2, trained: .yes, onPeriod: .yes, emotion: .neutral, intensity: 2,
                     journal: "Cramps easing off."),
        sampleReview(daysFromToday: -1, trained: .yes, onPeriod: .no, emotion: .calm, intensity: 3,
                     journal: "Feeling better, energy coming back.")
    ]

    private static func sampleReview(daysFromToday: Int,
                                     trained: ReviewAnswer,
                                     onPeriod: ReviewAnswer,
                                     emotion: Emotion,
                                     intensity: Int,
                                     journal: String) -> PollAnswers {
        let day = Calendar.current.date(byAdding: .day, value: daysFromToday, to: Date().startOfDay)!
        var review = PollAnswers(date: day)
        review.setAnswer(trained, for: .trained)
        review.setAnswer(onPeriod, for: .onPeriod)
        review.emotion = emotion
        review.intensity = intensity
        review.journal = journal
        return review
    }

    private static func sampleProgram(daysFromToday: Int,
                                      day: Int,
                                      duration: Int,
                                      type: ExerciseType,
                                      workouts: [(name: String, sets: Int?)]) -> ExerciseProgram {
        let date = Calendar.current.date(byAdding: .day, value: daysFromToday, to: Date().startOfDay)!
            .addingTimeInterval(9 * 60 * 60) // 9am
        return ExerciseProgram(
            date: date,
            day: day,
            exerciseDuration: duration,
            numberOfExercises: workouts.count,
            exerciseType: type,
            workouts: workouts.map { Workout(name: $0.name, sets: $0.sets, reps: $0.sets == nil ? nil : 10, restSeconds: 10) }
        )
    }
}

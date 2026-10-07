//
//  MockPeriodTRepository.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//

import Foundation

/// In-memory sample data for previews and for running without Supabase.
/// Programs added with `addProgram` are kept until the app quits.
final class MockPeriodTRepository: IPeriodTRepository {

    private var programs: [ExerciseProgram]
    private let delay: Duration
    private let shouldFail: Bool

    /// - Parameters:
    ///   - programs: Starting data. Defaults to `samplePrograms`.
    ///   - delay: Fake network wait, handy for seeing loading states.
    ///   - shouldFail: Throw from every call, handy for previewing error states.
    init(programs: [ExerciseProgram] = MockPeriodTRepository.samplePrograms,
         delay: Duration = .zero,
         shouldFail: Bool = false) {
        self.programs = programs
        self.delay = delay
        self.shouldFail = shouldFail
    }

    func fetchWorkouts() async throws -> [ExerciseProgram] {
        try await simulateNetwork()
        return programs.sorted { $0.date < $1.date }
    }

    func addProgram(_ program: ExerciseProgram) async throws {
        try await simulateNetwork()
        programs.append(program)
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
    /// Dates are relative to today, so there's always a mix of past (lavender) and upcoming (pink) programs.
    /// Workout names match `ExerciseImages.csv`, so thumbnails show up.
    static let samplePrograms: [ExerciseProgram] = [
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
        ])
    ]

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
            workouts: workouts.map { Workout(name: $0.name, sets: $0.sets) }
        )
    }
}

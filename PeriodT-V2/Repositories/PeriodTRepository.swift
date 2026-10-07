//
//  PeriodTReposioty.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import Foundation
import Supabase

struct PeriodTRepository: IPeriodTRepository {
    
    private let client: SupabaseClient
    
    init(projectURL: URL, publishableKey: String) {
        self.client = SupabaseClient(supabaseURL: projectURL, supabaseKey: publishableKey)
    }
    
    /// Fetches shared programs plus the user's own, each with its workouts nested inside, soonest first.
    func fetchWorkouts() async throws -> [ExerciseProgram] {
        // If sign-in fails, still show the shared programs rather than an error.
        try? await signInIfNeeded()
        return try await client
            .from("exercise_programs")
            .select("*, workouts(*)")
            .order("date")
            .order("position", referencedTable: "workouts")
            .execute()
            .value
    }
    
    /// Saves a program, then its workouts. The database fills in `user_id` from the signed-in user.
    func addProgram(_ program: ExerciseProgram) async throws {
        try await signInIfNeeded()
        
        try await client
            .from("exercise_programs")
            .insert(ProgramRow(program))
            .execute()
        
        let workoutRows = program.workouts.enumerated().map { index, workout in
            WorkoutRowModel(workout, programID: program.id, position: index)
        }
        guard !workoutRows.isEmpty else { return }
        
        try await client
            .from("workouts")
            .insert(workoutRows)
            .execute()
    }
    
    /// Gives this device its own Supabase user the first time, with no login screen.
    /// The session is saved in the Keychain, so later launches reuse the same user.
    private func signInIfNeeded() async throws {
        if client.auth.currentSession == nil {
            try await client.auth.signInAnonymously()
        }
    }
}

// MARK: - Insert payloads

/// The columns of `exercise_programs`. `ExerciseProgram` itself can't be inserted
/// directly because `workouts` lives in its own table, not in a column.
private struct ProgramRow: Encodable {
    let id: UUID
    let date: Date
    let day: Int
    let exerciseDuration: Int
    let numberOfExercises: Int
    let exerciseType: ExerciseType
    
    init(_ program: ExerciseProgram) {
        id = program.id
        date = program.date
        day = program.day
        exerciseDuration = program.exerciseDuration
        numberOfExercises = program.numberOfExercises
        exerciseType = program.exerciseType
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, day
        case exerciseDuration = "exercise_duration"
        case numberOfExercises = "number_of_exercises"
        case exerciseType = "exercise_type"
    }
}

/// The columns of `workouts`, including which program it belongs to and its order.
private struct WorkoutRowModel: Encodable {
    let id: UUID
    let programID: UUID
    let name: String
    let sets: Int?
    let position: Int
    
    init(_ workout: Workout, programID: UUID, position: Int) {
        id = workout.id
        self.programID = programID
        name = workout.name
        sets = workout.sets
        self.position = position
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, sets, position
        case programID = "program_id"
    }
}

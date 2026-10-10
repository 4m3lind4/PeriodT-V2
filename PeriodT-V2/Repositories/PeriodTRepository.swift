//
//  PeriodTRepository.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  The real repository, backed by Supabase. I went with Supabase over Core Data
//  because programs need to be shared between athletes and coaches across devices.
//  Each device signs in anonymously and row-level security keeps every athlete's
//  check-ins private to them.
//

import Foundation
import Supabase

struct PeriodTRepository: IPeriodTRepository {
    
    private let client: SupabaseClient
    private let signIn = AnonymousSignIn()
    
    init(projectURL: URL, publishableKey: String) {
        self.client = SupabaseClient(supabaseURL: projectURL, supabaseKey: publishableKey)
    }
    
    /// Shared programs plus the athlete's own, soonest first, with workouts nested inside.
    /// Each workout comes with this athlete's completion row (if there is one), which is
    /// how ticks survive the app being closed.
    func fetchWorkouts() async throws -> [ExerciseProgram] {
        // If sign-in fails the shared programs can still be shown, so don't throw here.
        try? await signInIfNeeded()
        return try await client
            .from("exercise_programs")
            .select("*, workouts(*, workout_completions(completed_at))")
            .order("date")
            .order("position", referencedTable: "workouts")
            .execute()
            .value
    }
    
    /// Saves the program, then its workouts. These are two separate requests, so if the
    /// second one fails the program row is already in. Both skip rows that already exist,
    /// which means a retry just finishes the job instead of failing on a duplicate id.
    func addProgram(_ program: ExerciseProgram) async throws {
        try await signInIfNeeded()
        
        try await client
            .from("exercise_programs")
            .upsert(ProgramRow(program), onConflict: "id", ignoreDuplicates: true)
            .execute()
        
        let workoutRows = program.workouts.enumerated().map { index, workout in
            WorkoutRowModel(workout, programID: program.id, position: index)
        }
        guard !workoutRows.isEmpty else { return }
        
        try await client
            .from("workouts")
            .upsert(workoutRows, onConflict: "id", ignoreDuplicates: true)
            .execute()
    }
    
    /// Adds rows for newly ticked workouts and removes rows for unticked ones. RLS makes
    /// sure the delete can only ever touch this athlete's rows.
    func saveCompletedWorkouts(_ completedIDs: Set<Workout.ID>, in program: ExerciseProgram) async throws {
        try await signInIfNeeded()

        let ticked = program.workouts.filter { completedIDs.contains($0.id) }
        let unticked = program.workouts.filter { !completedIDs.contains($0.id) }

        if !ticked.isEmpty {
            // ignoreDuplicates keeps the original completed_at on workouts that were already ticked.
            try await client
                .from("workout_completions")
                .upsert(ticked.map { CompletionRow(workoutID: $0.id) },
                        onConflict: "user_id,workout_id",
                        ignoreDuplicates: true)
                .execute()
        }

        if !unticked.isEmpty {
            try await client
                .from("workout_completions")
                .delete()
                .in("workout_id", values: unticked.map(\.id))
                .execute()
        }
    }

    /// No filter needed, RLS only hands back this athlete's rows.
    func fetchPollAnswers() async throws -> [PollAnswers] {
        try await signInIfNeeded()
        return try await client
            .from("daily_reviews")
            .select("day, answers, emotion, intensity, journal")
            .execute()
            .value
    }

    /// One row per user per day, so saving the same day again overwrites it.
    func savePollAnswers(_ answers: PollAnswers) async throws {
        try await signInIfNeeded()
        try await client
            .from("daily_reviews")
            .upsert(answers, onConflict: "user_id,day")
            .execute()
    }

    /// Gives this device its own Supabase user the first time round, with no login screen.
    /// The session is kept in the Keychain so later launches carry on as the same user.
    private func signInIfNeeded() async throws {
        try await signIn.ensureSignedIn(client)
    }
}

/// On first launch several screens load at once. Without this, each one would see no
/// session and make its own anonymous user, splitting the athlete's data across them.
/// Anyone who turns up while a sign-in is already running just waits for that one.
private actor AnonymousSignIn {
    private var inFlight: Task<Void, Error>?

    func ensureSignedIn(_ client: SupabaseClient) async throws {
        guard client.auth.currentSession == nil else { return }
        if let inFlight {
            return try await inFlight.value
        }
        let task = Task { _ = try await client.auth.signInAnonymously() }
        inFlight = task
        // Cleared whether it worked or not, so a failed attempt can be retried next time.
        defer { inFlight = nil }
        try await task.value
    }
}

// MARK: - Insert payloads

/// The columns of `exercise_programs`. `ExerciseProgram` can't be inserted as-is
/// because its workouts live in their own table, not a column.
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
    let reps: Int?
    let restSeconds: Int?
    let position: Int
    
    init(_ workout: Workout, programID: UUID, position: Int) {
        id = workout.id
        self.programID = programID
        name = workout.name
        sets = workout.sets
        reps = workout.reps
        restSeconds = workout.restSeconds
        self.position = position
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps, position
        case restSeconds = "rest_seconds"
        case programID = "program_id"
    }
}

/// A row in `workout_completions`. The database fills in `user_id` and `completed_at`.
private struct CompletionRow: Encodable {
    let workoutID: UUID

    enum CodingKeys: String, CodingKey {
        case workoutID = "workout_id"
    }
}

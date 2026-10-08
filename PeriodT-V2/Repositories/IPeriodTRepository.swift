//
//  IPeriodTReposity.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import Foundation

protocol IPeriodTRepository {
    func fetchWorkouts() async throws -> [ExerciseProgram]
    func addProgram(_ program: ExerciseProgram) async throws
    /// Makes `completedIDs` the full set of ticked workouts in `program` for the current user.
    func saveCompletedWorkouts(_ completedIDs: Set<Workout.ID>, in program: ExerciseProgram) async throws
}

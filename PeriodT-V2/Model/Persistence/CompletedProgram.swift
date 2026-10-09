//
//  CompletedProgram.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation
import SwiftData

/// One record per submitted program, keyed to the day the program was due.
@Model
final class CompletedProgram {
    /// The program's scheduled date, normalised to `startOfDay`.
    var date: Date
    var programDay: Int
    var exerciseType: String
    /// Names of the workouts the user ticked off before submitting.
    var completedWorkouts: [String]
    var submittedAt: Date

    init(program: ExerciseProgram, completedWorkouts: [String]) {
        self.date = program.date.startOfDay
        self.programDay = program.day
        self.exerciseType = program.exerciseType.title
        self.completedWorkouts = completedWorkouts
        self.submittedAt = .now
    }
}

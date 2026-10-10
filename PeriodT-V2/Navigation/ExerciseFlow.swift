//
//  ExerciseFlow.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import Foundation

/// Steps in the post-program flow that are pushed onto the exercise stack.
enum ExerciseFlow: Hashable {
    /// The "Great Job" screen for the program that was just submitted.
    case completed(ExerciseProgram)
}

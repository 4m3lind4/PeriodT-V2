//
//  ExerciseFlow.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  Destinations that get pushed onto the exercise NavigationStack.
//

import Foundation

enum ExerciseFlow: Hashable {
    /// The "Great Job" screen for the program that was just submitted.
    case completed(ExerciseProgram)
}

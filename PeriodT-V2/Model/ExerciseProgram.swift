//
//  ExerciseProgram.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//


//
//  ExerciseProgram.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation
import SwiftUI

/// A single scheduled workout session assigned by the coach.
struct ExerciseProgram: Identifiable, Hashable, Codable {
    var id = UUID()
    let date: Date
    let day: Int
    let exerciseDuration: Int
    let numberOfExercises: Int
    let exerciseType: ExerciseType
    let workouts: [Workout]

    /// Maps Swift property names to the snake_case columns in Supabase.
    enum CodingKeys: String, CodingKey {
        case id, date, day, workouts
        case exerciseDuration = "exercise_duration"
        case numberOfExercises = "number_of_exercises"
        case exerciseType = "exercise_type"
    }

    var formattedDate: String {
        date.formattedProgramDate()
    }
    
    /// Upcoming programs are pink, past ones fade to lavender.
    /// Compares whole dates, not day-of-month, so month boundaries work.
    var color: Color {
        if date.startOfDay >= Date().startOfDay {
            CoreColor.primary
        } else {
            CoreColor.lavender
        }
    }
    
    private static let dateNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    
    /// Day-of-month as an Int (e.g. 14 for the 14th).
    func dateNumber(date: Date) -> Int {
        Int(Self.dateNumberFormatter.string(from: date)) ?? 0
    }
}


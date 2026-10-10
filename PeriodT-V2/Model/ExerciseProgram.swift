//
//  ExerciseProgram.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  A training session the coach has set (physio or conditioning) and its list of
//  workouts. This maps straight onto the `exercise_programs` table in Supabase.
//

import Foundation
import SwiftUI

struct ExerciseProgram: Identifiable, Hashable, Codable {
    var id = UUID()
    let date: Date
    let day: Int
    let exerciseDuration: Int
    let numberOfExercises: Int
    let exerciseType: ExerciseType
    let workouts: [Workout]

    /// Supabase columns are snake_case, Swift is camelCase.
    enum CodingKeys: String, CodingKey {
        case id, date, day, workouts
        case exerciseDuration = "exercise_duration"
        case numberOfExercises = "number_of_exercises"
        case exerciseType = "exercise_type"
    }

    var formattedDate: String {
        date.formattedProgramDate()
    }
    private static let dateNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    
    /// The day of the month as a number, e.g. 14 for the 14th.
    func dateNumber(date: Date) -> Int {
        Int(Self.dateNumberFormatter.string(from: date)) ?? 0
        
    }
    
    
}


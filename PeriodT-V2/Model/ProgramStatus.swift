//
//  ProgramStatus.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Where a program sits relative to today and whether it was done.
/// Drives grouping and the card's stripe colour.
enum ProgramStatus {
    case completed, missed, current, incoming

    var color: Color {
        switch self {
        case .completed: CoreColor.completed
        case .missed:    CoreColor.missed
        case .current:   CoreColor.current
        case .incoming:  CoreColor.incoming
        }
    }
}

extension ExerciseProgram {
    /// Every workout has been ticked off. A program with no workouts is never complete.
    var isCompleted: Bool {
        !workouts.isEmpty && workouts.allSatisfy(\.isCompleted)
    }

    /// Today is current and later days are incoming. Earlier days are completed
    /// only if every workout was ticked, otherwise missed.
    var status: ProgramStatus {
        if Calendar.current.isDateInToday(date) { return .current }
        if date > Date() { return .incoming }
        return isCompleted ? .completed : .missed
    }
}

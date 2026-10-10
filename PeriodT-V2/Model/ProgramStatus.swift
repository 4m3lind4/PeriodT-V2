//
//  ProgramStatus.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  Sorts programs into completed, missed, current and incoming, which decides
//  how they're grouped and what colour their stripe is.
//

import SwiftUI

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
    /// Every workout is ticked off. An empty program never counts as complete.
    var isCompleted: Bool {
        !workouts.isEmpty && workouts.allSatisfy(\.isCompleted)
    }

    /// Today is current and anything later is incoming. Past days only count as
    /// completed if every workout was ticked, otherwise they're missed.
    var status: ProgramStatus {
        if Calendar.current.isDateInToday(date) { return .current }
        if date > Date() { return .incoming }
        return isCompleted ? .completed : .missed
    }
}

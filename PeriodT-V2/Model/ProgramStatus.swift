//
//  ProgramStatus.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Where a program sits relative to today. Drives grouping and the card's stripe colour.
enum ProgramStatus {
    case completed, current, incoming

    var color: Color {
        switch self {
        case .completed: CoreColor.completed
        case .current:   CoreColor.current
        case .incoming:  CoreColor.incoming
        }
    }
}

extension ExerciseProgram {
    /// Today is current, earlier days are completed, later days are incoming.
    var status: ProgramStatus {
        if Calendar.current.isDateInToday(date) { return .current }
        return date < Date() ? .completed : .incoming
    }
}

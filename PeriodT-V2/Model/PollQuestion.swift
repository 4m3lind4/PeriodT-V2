//
//  PollQuestion.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
import Foundation
import SwiftUI

/// Stable identifier for each poll question. The raw string is what gets persisted.
enum PollQuestionKind: String, Codable, CaseIterable {
    case trained
    case onPeriod
    case informCoachPeriod
    case informCoachWorkout
}

/// Display data for one yes/no question card.
struct PollQuestion: Identifiable {
    let kind: PollQuestionKind
    let text: String
    let color: Color

    var id: PollQuestionKind { kind }
}

extension PollQuestionKind {
    /// Compact heading used on the calendar's review summary.
    var summaryTitle: String {
        switch self {
        case .trained: "Did you practice today?"
        case .onPeriod: "Were you on your period?"
        case .informCoachPeriod: "Inform coach about period?"
        case .informCoachWorkout: "Update coach about workout?"
        }
    }
}

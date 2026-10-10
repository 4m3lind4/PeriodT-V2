//
//  PollQuestion.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The daily check-in questions. The kind is what gets saved, the struct is
//  just what the card needs to draw itself.
//

import Foundation
import SwiftUI

/// The raw string is what's saved, so don't rename these once they're in use.
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
    /// Shorter wording for the calendar's review summary.
    var summaryTitle: String {
        switch self {
        case .trained: "Did you practice today?"
        case .onPeriod: "Were you on your period?"
        case .informCoachPeriod: "Inform coach about period?"
        case .informCoachWorkout: "Update coach about workout?"
        }
    }
}

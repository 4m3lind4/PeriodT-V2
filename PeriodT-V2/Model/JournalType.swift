//
//  JournalType.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Tags a journal entry as emotional (from the daily check-in) or workout
//  (written after finishing a program).
//

import SwiftUI

/// Shown as the coloured tag on each entry in the Journal tab.
enum JournalType: String, CaseIterable, Codable, Identifiable {
    case emotional
    case workout

    var id: String { rawValue }

    var title: String { rawValue.capitalized }

    /// Pink for workout, orange for emotional.
    var color: Color {
        switch self {
        case .workout: CoreColor.primary
        case .emotional: CoreColor.accent
        }
    }
}

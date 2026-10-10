//
//  JournalType.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI

/// Which journal an entry came from. Shown as the coloured tag on the Journal page.
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

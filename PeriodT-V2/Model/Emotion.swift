//
//  Emotion.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The five moods an athlete can pick in the daily check-in, and the face icon for each.
//

import Foundation
import SwiftUI

/// String-backed so it saves to Supabase as plain text.
enum Emotion: String, CaseIterable, Identifiable {
    case happy
    case calm
    case neutral
    case sad
    case stressed

    var id: Self { self }
}

extension Emotion {
    /// Face icon from the asset catalogue.
    var image: ImageResource {
        
        switch self {
        case .happy:
            return .faceHappy
        case .calm:
            return .faceContent
        case .neutral:
            return .faceNeutral
        case .sad:
            return .faceFrown
        case .stressed:
            return .faceSad
        }
    }
    
}

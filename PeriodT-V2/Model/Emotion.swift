//
//  Emotion.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation
import SwiftUI

/// String-backed so it can be stored on `PollAnswers`.
enum Emotion: String, CaseIterable, Identifiable {
    case happy
    case calm
    case neutral
    case sad
    case stressed

    var id: Self { self }
}

extension Emotion {
    /// Asset-catalog face icon for each emotion.
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

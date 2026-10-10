//
//  ExerciseType.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  The two kinds of program: physio and conditioning.
//

import Foundation

enum ExerciseType: String, CaseIterable, Codable {
    case physio
    case conditioningTraining
    
}

extension ExerciseType {
    var title: String {
        
        switch self {
        case .physio:
            return "Physio"
        case .conditioningTraining:
            return "Conditioning"
        }
    }
    
}

//
//  ReviewAnswer.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  A yes/no answer to one of the daily check-in questions.
//

import Foundation

/// The raw string is what gets saved.
enum ReviewAnswer: String, Codable, Equatable {
    case yes
    case no
}

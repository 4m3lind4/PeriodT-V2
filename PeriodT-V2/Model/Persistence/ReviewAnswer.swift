//
//  ReviewAnswer.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import Foundation

/// Yes/no answer for a poll question. Raw string is what gets stored.
enum ReviewAnswer: String, Codable, Equatable {
    case yes
    case no
}

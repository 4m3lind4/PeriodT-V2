//
//  EmotionalLevel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  One point on the forecast chart on Home (a menstrual and luteal reading per day).
//

import Foundation

struct EmotionalLevel: Identifiable {
    let id = UUID()
    let day: String
    let menstrualLevel: Double
    let lutealLevel: Double
}

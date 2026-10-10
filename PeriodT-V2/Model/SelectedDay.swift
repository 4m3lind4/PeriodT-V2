//
//  SelectedDay.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  Wraps a tapped calendar day so it can drive `.sheet(item:)`.
//

import Foundation

struct SelectedDay: Identifiable {
    let id: Date
    var date: Date { id }
}

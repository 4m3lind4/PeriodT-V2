//
//  Workout.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//


//
//  Workout.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation

/// One exercise inside a program. `sets` is optional for timed/untracked work.
struct Workout: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var sets: Int?
}

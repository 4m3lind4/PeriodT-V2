//
//  WorkoutActivityAttributes.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  The data passed from the app to the workout Live Activity. It's in both
//  targets because the app sends it and the extension draws it.
//

import Foundation
import ActivityKit

struct WorkoutActivityAttributes: ActivityAttributes {
    /// Changes as the athlete ticks off exercises.
    struct ContentState: Codable, Hashable {
        var currentExerciseName: String
        /// Short detail after the name, e.g. "3 × 10". Empty if there's nothing to show.
        var detail: String
        /// Which exercise they're on, counting from 0.
        var currentIndex: Int
    }

    /// These stay the same for the whole workout.
    var programName: String
    var totalExercises: Int
}

//
//  WorkoutActivityAttributes.swift
//  PeriodTWidgetExtension
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Foundation
import ActivityKit

/// Shared by the app (starts/updates the activity) and the widget extension (draws it),
/// so this file is a member of both targets.
struct WorkoutActivityAttributes: ActivityAttributes {
    /// Changes as the user ticks off exercises.
    struct ContentState: Codable, Hashable {
        var currentExerciseName: String
        /// Short detail under the name, e.g. "3 × 10".
        var detail: String
        /// 0-based index of the exercise the user is on.
        var currentIndex: Int
    }

    /// Fixed for the whole workout.
    var programName: String
    var totalExercises: Int
}

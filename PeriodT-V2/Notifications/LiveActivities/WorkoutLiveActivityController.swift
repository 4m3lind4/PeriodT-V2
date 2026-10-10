//
//  WorkoutLiveActivityController.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import ActivityKit
import OSLog

/// Starts, updates and ends the lock screen Live Activity for a program in progress.
@MainActor
final class WorkoutLiveActivityController {
    private static let logger = Logger(subsystem: "PeriodT", category: "WorkoutLiveActivity")

    private var activity: Activity<WorkoutActivityAttributes>?

    /// Shows the activity, or updates it if one is already running for this program.
    func show(program: ExerciseProgram, currentIndex: Int) {
        guard !program.workouts.isEmpty else { return }
        let state = Self.state(for: program, at: currentIndex)

        if let activity {
            Task { await activity.update(.init(state: state, staleDate: nil)) }
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WorkoutActivityAttributes(
            programName: "\(program.formattedDate) Program",
            totalExercises: program.workouts.count
        )
        do {
            activity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            Self.logger.error("Failed to start workout Live Activity: \(error.localizedDescription)")
        }
    }

    /// Removes the activity from the lock screen.
    func end() {
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
    }

    private static func state(for program: ExerciseProgram, at index: Int) -> WorkoutActivityAttributes.ContentState {
        let index = min(max(index, 0), program.workouts.count - 1)
        let workout = program.workouts[index]
        var detail = ""
        if let sets = workout.sets, let reps = workout.reps {
            detail = "\(sets) × \(reps)"
        } else if let sets = workout.sets {
            detail = "\(sets) sets"
        }
        return .init(currentExerciseName: workout.name, detail: detail, currentIndex: index)
    }
}

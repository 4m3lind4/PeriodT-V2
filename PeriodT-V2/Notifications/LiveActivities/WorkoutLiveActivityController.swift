//
//  WorkoutLiveActivityController.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Runs the Lock Screen Live Activity while an athlete works through a program,
//  so they can see which exercise they're up to without unlocking their phone
//  mid-session. The views only call `show` and `end`, all the ActivityKit stuff
//  stays in here.
//

import ActivityKit
import OSLog

@MainActor
final class WorkoutLiveActivityController {
    private static let logger = Logger(subsystem: "PeriodT", category: "WorkoutLiveActivity")

    private var activity: Activity<WorkoutActivityAttributes>?

    /// Starts the activity, or just updates it if one is already running.
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

    /// What the Lock Screen shows for the exercise at `index`. The index gets clamped so
    /// a stale value can't crash it, and the detail line is "3 × 10", "3 sets" or blank.
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

//
//  ActiveInProgramView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI
import OSLog

/// Checklist screen for the program the user has just started.
struct ActiveInProgramView: View {
    private static let logger = Logger(subsystem: "PeriodT", category: "ActiveInProgramView")

    let program: ExerciseProgram
    let repository: IPeriodTRepository
    @EnvironmentObject private var navigation: AppNavigationViewModel
    @Environment(\.presentError) private var presentError
    // IDs of workouts the user has ticked so far.
    // Starts from what's already saved in Supabase so earlier ticks show up.
    @State private var completedWorkoutIDs: Set<Workout.ID>
    @State private var isSaving = false

    init(program: ExerciseProgram, repository: IPeriodTRepository) {
        self.program = program
        self.repository = repository
        _completedWorkoutIDs = State(initialValue: Set(program.workouts.filter(\.isCompleted).map(\.id)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: "Today's Program")
                .padding(10)

            ScrollView {
                VStack(spacing: 24) {
                    ForEach(program.workouts) { workout in
                        // Bind each row's checkbox to membership in the set.
                        WorkoutChecklistRow(
                            workout: workout,
                            isChecked: Binding(
                                get: { completedWorkoutIDs.contains(workout.id) },
                                set: { checked in
                                    if checked {
                                        completedWorkoutIDs.insert(workout.id)
                                    } else {
                                        completedWorkoutIDs.remove(workout.id)
                                    }
                                }
                            )
                        )
                    }

                    // Save, then push the "Great Job" screen. On failure the
                    // user stays here with an error card so they can retry.
                    Button {
                        Task {
                            if await submitProgram() {
                                navigation.exercisePath.append(ExerciseFlow.completed)
                            } else {
                                presentError(.saveFailed(.workout))
                            }
                        }
                    } label: {
                        PrimaryButtonLabel(title: isSaving ? "Saving..." : "Submit")
                    }
                    // Stops a double tap sending the save twice.
                    .disabled(isSaving)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(CoreColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .ignoresSafeArea(edges: .bottom)
        }
    }

    /// Saves the ticked workouts to Supabase. Returns false if the save failed,
    /// leaving the ticks in place so the user can retry.
    private func submitProgram() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.saveCompletedWorkouts(completedWorkoutIDs, in: program)
            return true
        } catch {
            Self.logger.error("Failed to save completed workouts for day \(program.day): \(error.localizedDescription)")
            return false
        }
    }
}

#Preview {
    NavigationStack {
        // Fake program so the preview doesn't need Supabase.
        ActiveInProgramView(program: ExerciseProgram(
            date: .now,
            day: 1,
            exerciseDuration: 45,
            numberOfExercises: 3,
            exerciseType: .conditioningTraining,
            workouts: [
                Workout(name: "Goblet Squat", sets: 4, isCompleted: true),
                Workout(name: "Kettlebell Swing", sets: 3),
                Workout(name: "Rowing Machine")
            ]
        ), repository: MockPeriodTRepository())
    }
    .errorCardHost()
    .environmentObject(AppNavigationViewModel())
}

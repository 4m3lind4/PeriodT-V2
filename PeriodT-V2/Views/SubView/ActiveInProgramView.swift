//
//  ActiveInProgramView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  The screen an athlete works through during a program. Each exercise is a
//  card with a progress line down the side that fills in as they go. Ticks are
//  kept locally while they train and only saved to Supabase on Submit, and the
//  Live Activity is kept in step so the Lock Screen shows the current exercise.
//

import SwiftUI
import OSLog

struct ActiveInProgramView: View {
    private static let logger = Logger(subsystem: "PeriodT", category: "ActiveInProgramView")

    let program: ExerciseProgram
    let repository: IPeriodTRepository
    @EnvironmentObject private var navigation: AppNavigationViewModel
    @Environment(\.presentError) private var presentError
    /// Which sets are ticked for each workout. Only finished workouts get saved on
    /// Submit, so this resets if the athlete leaves halfway through.
    @State private var completedSets: [Workout.ID: Set<Int>]
    /// Which workout's sets are open.
    @State private var openWorkoutID: Workout.ID?
    @State private var isSaving = false
    @State private var liveActivity = WorkoutLiveActivityController()
    /// How deep the exercise stack was when this screen appeared. When it disappears
    /// we compare against this to tell backing out (stack got shorter) apart from
    /// opening a workout or switching tabs.
    @State private var stackDepth = 0

    init(program: ExerciseProgram, repository: IPeriodTRepository) {
        self.program = program
        self.repository = repository

        var sets: [Workout.ID: Set<Int>] = [:]
        for workout in program.workouts where workout.isCompleted {
            sets[workout.id] = Set(0..<workout.setCount)
        }
        _completedSets = State(initialValue: sets)
    }

    private var title: String { "\(program.formattedDate) Program" }

    /// Workouts with every set ticked, which is what gets saved.
    private var completedWorkoutIDs: Set<Workout.ID> {
        Set(program.workouts.filter(isFinished).map(\.id))
    }

    /// The first unfinished exercise, or the last one once everything's done.
    private var currentWorkoutIndex: Int {
        program.workouts.firstIndex { !isFinished($0) } ?? max(program.workouts.count - 1, 0)
    }

    private func isFinished(_ workout: Workout) -> Bool {
        (completedSets[workout.id]?.count ?? 0) >= workout.setCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: title)
                .padding(10)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(program.workouts.enumerated()), id: \.element.id) { index, workout in
                        workoutRow(workout, at: index)
                    }

                    // Save first, then move on to the "Great Job" screen. If it fails they
                    // stay here with an error card and their ticks intact so they can retry.
                    Button {
                        Task {
                            if await submitProgram() {
                                liveActivity.end()
                                navigation.exercisePath.append(ExerciseFlow.completed(program))
                            } else {
                                presentError(.saveFailed(.workout))
                            }
                        }
                    } label: {
                        PrimaryButtonLabel(title: isSaving ? "Saving..." : "Submit")
                    }
                    // Stops a double tap saving twice.
                    .disabled(isSaving)
                    .padding(.top, 24)
                }
                .padding(.leading, 12)
                .padding(.trailing, 20)
                .padding(.vertical, 12)
            }
            // Stops Submit hiding behind the tab bar on long programs.
            .contentMargins(.bottom, 100, for: .scrollContent)
            .background(CoreColor.primary)
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationDestination(item: $openWorkoutID) { id in
            if let workout = program.workouts.first(where: { $0.id == id }) {
                WorkoutSetsView(title: title, workout: workout, completedSets: setsBinding(for: id))
            }
        }
        // Show progress on the Lock Screen while the program is open.
        .onAppear {
            stackDepth = navigation.exercisePath.count
            liveActivity.show(program: program, currentIndex: currentWorkoutIndex)
        }
        // If they back out without submitting, don't leave it sitting on the Lock Screen.
        .onDisappear {
            if navigation.exercisePath.count < stackDepth {
                liveActivity.end()
            }
        }
        .onChange(of: currentWorkoutIndex) { _, index in
            liveActivity.show(program: program, currentIndex: index)
        }
    }

    /// The progress line plus the card. The vertical padding sits inside the row so
    /// each bit of line meets the next row's with no gap.
    private func workoutRow(_ workout: Workout, at index: Int) -> some View {
        Button {
            openWorkoutID = workout.id
        } label: {
            WorkoutProgressCard(workout: workout)
        }
        .buttonStyle(.plain)
        .padding(.leading, Timeline.columnWidth)
        .padding(.vertical, 10)
        .background(alignment: .leading) {
            Timeline(
                // The line comes in from above once the previous exercise is done,
                lineAbove: index > 0 && isFinished(program.workouts[index - 1]),
                // and carries on down once this one's done, pointing at the next.
                lineBelow: index < program.workouts.count - 1 && isFinished(workout),
                isFilled: isFinished(workout)
            )
        }
        .animation(.snappy, value: isFinished(workout))
    }

    private func setsBinding(for id: Workout.ID) -> Binding<Set<Int>> {
        Binding(
            get: { completedSets[id] ?? [] },
            set: { completedSets[id] = $0 }
        )
    }

    /// Saves the ticked workouts. Returns false if it failed, and the ticks stay put
    /// so the athlete can try again.
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
        // A made-up program so the preview doesn't need Supabase.
        ActiveInProgramView(program: ExerciseProgram(
            date: .now,
            day: 1,
            exerciseDuration: 45,
            numberOfExercises: 4,
            exerciseType: .conditioningTraining,
            workouts: [
                Workout(name: "Goblet Squat", sets: 3, reps: 10, restSeconds: 10, isCompleted: true),
                Workout(name: "Kettlebell Swing", sets: 3, reps: 12, restSeconds: 30),
                Workout(name: "Hip Thrust", sets: 3, reps: 10, restSeconds: 20),
                Workout(name: "Rowing Machine")
            ]
        ), repository: MockPeriodTRepository())
    }
    .errorCardHost()
    .environmentObject(AppNavigationViewModel())
}

/// One row's piece of the progress line: a circle, with a bit of line above and below when needed.
private struct Timeline: View {
    static let columnWidth: CGFloat = 46
    private let circleSize: CGFloat = 28
    private let lineWidth: CGFloat = 4

    let lineAbove: Bool
    let lineBelow: Bool
    let isFilled: Bool

    var body: some View {
        VStack(spacing: 0) {
            segment(isVisible: lineAbove)

            Circle()
                .fill(isFilled ? CoreColor.white : .clear)
                .strokeBorder(CoreColor.white, lineWidth: lineWidth)
                .frame(width: circleSize, height: circleSize)

            segment(isVisible: lineBelow)
        }
        .frame(width: Self.columnWidth)
        .accessibilityHidden(true)
    }

    private func segment(isVisible: Bool) -> some View {
        Rectangle()
            .fill(CoreColor.white)
            .frame(width: lineWidth)
            .frame(maxHeight: .infinity)
            .opacity(isVisible ? 1 : 0)
    }
}

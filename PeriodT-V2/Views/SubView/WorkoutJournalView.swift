//
//  WorkoutJournalView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  The workout journal on the completed-program screen. Each program gets its
//  own entry, kept separate from the emotional journal on Home.
//

import SwiftUI

/// Saved against the program's day, keyed by the program's id.
struct WorkoutJournalView: View {
    @EnvironmentObject private var store: TrackingStore
    @Environment(\.presentError) private var presentError

    let program: ExerciseProgram

    private var day: Date { program.date.startOfDay }

    var body: some View {
        JournalTextEditor(
            title: "Workout Journal",
            titleColor: CoreColor.ringBackground,
            notes: Binding(
                get: { store.review(for: day)?.workoutJournal(for: program.id) ?? "" },
                set: { newValue in
                    store.update(day, onFailure: { presentError(.saveFailed(.journal)) }) {
                        $0.setWorkoutJournal(newValue, for: program.id)
                    }
                }
            )
        )
    }
}

#Preview {
    WorkoutJournalView(program: MockPeriodTRepository.samplePrograms[0])
        .padding()
        .background(CoreColor.primary)
        .previewTrackingStore()
}

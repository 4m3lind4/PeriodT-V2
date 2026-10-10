//
//  WorkoutJournalView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Journal styled for the pink completed-program screen. Each program keeps its
/// own entry (on the program's day), separate from Home's emotional journal.
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

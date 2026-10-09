//
//  DayPollView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI
import SwiftData

/// The stack of poll question cards for a single day, reading and
/// writing answers straight into that day's `PollAnswers` record.
struct DayPollView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentError) private var presentError
    @StateObject private var viewModel = DayPoleModel()

    let day: Date

    @State private var record: PollAnswers?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.questions) { question in
                // Each card reads/writes directly into the SwiftData record.
                QuestionCardView(
                    selectedAnswer: Binding(
                        get: { record?.answer(for: question) },
                        set: { newValue in
                            guard let newValue else { return }
                            update(.pollAnswer) { $0.setAnswer(newValue, for: question) }
                        }
                    ),
                    question: question.text,
                    color: question.color
                )
            }
            EmotionPollView(
                selectedEmotion: Binding(
                    get: { record?.emotion },
                    set: { newValue in update(.pollAnswer) { $0.emotion = newValue } }
                )
            )
            IntensitySliderView(
                selectedIntensity: Binding(
                    get: { record?.intensity ?? IntensitySliderView.defaultIntensity },
                    set: { newValue in
                        // The slider fires on every drag sample; skip no-op writes.
                        guard newValue != record?.intensity else { return }
                        update(.pollAnswer) { $0.intensity = newValue }
                    }
                )
            )
            JournalView(
                notes: Binding(
                    get: { record?.journal ?? "" },
                    set: { newValue in update(.journal) { $0.journal = newValue } }
                )
            )
        }
        .onAppear {
            record = PollAnswers.fetchOrCreate(for: day, in: modelContext)
        }
    }

    /// Applies `mutate` to the day's record (creating it on first use),
    /// saves immediately, and raises the error card if the save fails.
    private func update(_ target: AppError.SaveTarget, _ mutate: (PollAnswers) -> Void) {
        let current = record ?? PollAnswers.fetchOrCreate(for: day, in: modelContext)
        mutate(current)
        record = current
        if !PollAnswers.save(modelContext) {
            presentError(.saveFailed(target))
        }
    }
}

#Preview {
    DayPollView(day: .now)
        .errorCardHost()
        .modelContainer(for: PollAnswers.self, inMemory: true)
}

//
//  DayPollView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// The stack of poll question cards for a single day, reading and
/// writing that day's answers through the shared `TrackingStore`.
struct DayPollView: View {
    @EnvironmentObject private var store: TrackingStore
    @Environment(\.presentError) private var presentError
    @StateObject private var viewModel = DayPoleModel()

    let day: Date

    private var record: PollAnswers? { store.review(for: day) }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.questions) { question in
                // Each card reads/writes the day's review in the store.
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
    }

    /// Applies `mutate` to the day's review (creating it on first use) and
    /// raises the error card if the Supabase save fails.
    private func update(_ target: AppError.SaveTarget, _ mutate: (inout PollAnswers) -> Void) {
        store.update(day, onFailure: { presentError(.saveFailed(target)) }, mutate)
    }
}

#Preview {
    DayPollView(day: .now)
        .errorCardHost()
        .previewTrackingStore()
}

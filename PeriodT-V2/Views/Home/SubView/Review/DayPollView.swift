//
//  DayPollView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The daily check-in itself: yes/no questions, mood, intensity and journal for
//  one day. It's used on Home for today and in the calendar's day sheet for past
//  days, so both always read and write the same data through TrackingStore.
//

import SwiftUI

struct DayPollView: View {
    @EnvironmentObject private var store: TrackingStore
    @Environment(\.presentError) private var presentError
    @StateObject private var viewModel = DayPoleModel()

    let day: Date

    private var record: PollAnswers? { store.review(for: day) }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.questions) { question in
                // Every control is bound straight to the store rather than local @State,
                // so there's no copy of the answers to fall out of sync.
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
                        // The slider fires on every tiny drag movement, so skip it if nothing changed.
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

    /// Applies the change to this day's review (making one if needed) and pops up
    /// the error card if saving to Supabase fails.
    private func update(_ target: AppError.SaveTarget, _ mutate: (inout PollAnswers) -> Void) {
        store.update(day, onFailure: { presentError(.saveFailed(target)) }, mutate)
    }
}

#Preview {
    DayPollView(day: .now)
        .errorCardHost()
        .previewTrackingStore()
}

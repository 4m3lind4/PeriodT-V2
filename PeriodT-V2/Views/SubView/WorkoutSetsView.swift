//
//  WorkoutSetsView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI

/// One exercise opened from the in-progress list: a large photo, its prescription,
/// and one row per set that the user taps as they finish it.
/// When the last set is ticked it returns to the list, where the progress line moves on.
struct WorkoutSetsView: View {
    let title: String
    let workout: Workout
    /// Indexes (0-based) of the sets ticked so far. Owned by ActiveInProgramView.
    @Binding var completedSets: Set<Int>

    @Environment(\.dismiss) private var dismiss

    private var isFinished: Bool { completedSets.count >= workout.setCount }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScreenHeader(title: title)
                .padding(10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroImage

                    VStack(alignment: .leading, spacing: 12) {
                        Text(workout.name)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        if let prescription {
                            Text(prescription)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)

                    setList
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            // Keeps the last set clear of the floating tab bar.
            .contentMargins(.bottom, 100, for: .scrollContent)
            .background(CoreColor.primary)
            .ignoresSafeArea(edges: .bottom)
        }
    }

    /// "3 Sets of 10 Second Rest", leaving out whichever part isn't set.
    private var prescription: String? {
        let parts = [
            workout.sets.map { "\($0) Sets" },
            workout.restSeconds.map { "\($0) Second Rest" }
        ].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " | ")
    }

    /// The frame is sized first and the photo fills it, so a wide photo can't widen the page.
    private var heroImage: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 260)
            .overlay {
                AsyncImage(url: workout.imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundStyle(CoreColor.primary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(CoreColor.ringBackground)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var setList: some View {
        VStack(spacing: 0) {
            ForEach(0..<workout.setCount, id: \.self) { index in
                setRow(index)

                if index < workout.setCount - 1 {
                    Rectangle()
                        .fill(CoreColor.primary)
                        .frame(height: 1)
                        .padding(.leading, 58)
                        .padding(.trailing, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(CoreColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// The whole row is the tap target so it's easy to hit mid-workout.
    private func setRow(_ index: Int) -> some View {
        let isDone = completedSets.contains(index)

        return Button {
            toggle(index)
        } label: {
            HStack(spacing: 24) {
                Image(systemName: "play.circle")
                    .font(.system(size: 34, weight: .regular))

                // Reps for this set; untracked work just shows the set number.
                Text(workout.reps.map(String.init) ?? "Set \(index + 1)")
                    .font(.system(size: 17, weight: .bold, design: .rounded))

                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .fill(CoreColor.white)
                    .frame(width: 62, height: 56)
                    .overlay {
                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 26, weight: .bold))
                        }
                    }
            }
            .foregroundStyle(CoreColor.primary)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Set \(index + 1)")
        .accessibilityValue(isDone ? "Done" : "Not done")
        .sensoryFeedback(.success, trigger: isDone) { _, done in done }
    }

    private func toggle(_ index: Int) {
        withAnimation(.snappy) {
            if completedSets.contains(index) {
                completedSets.remove(index)
            } else {
                completedSets.insert(index)
            }
        }
        // Last set done: pause so the tick is visible, then head back to the list.
        if isFinished {
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                if isFinished { dismiss() }
            }
        }
    }
}

#Preview {
    @Previewable @State var sets: Set<Int> = [0]
    NavigationStack {
        WorkoutSetsView(
            title: "MON 7 SEP Program",
            workout: Workout(name: "Lunge with scooter - rowing machine", sets: 3, reps: 10, restSeconds: 10),
            completedSets: $sets
        )
    }
}

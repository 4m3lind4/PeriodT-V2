//
//  ReviewSummaryView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI

/// Read-only cards for a logged day review: a purple label strip over a pale answer.
/// Shows the first few, with View More to reveal the rest.
struct ReviewSummaryView: View {
    let review: PollAnswers

    @State private var showAll = false
    private let previewCount = 2

    /// One card per thing the user actually filled in, in the same order as the form.
    private var items: [SummaryItem] {
        var items: [SummaryItem] = []
        for kind in PollQuestionKind.allCases {
            if let answer = review.answers[kind] {
                items.append(SummaryItem(title: kind.summaryTitle, value: answer.rawValue.capitalized))
            }
        }
        if let emotion = review.emotion {
            items.append(SummaryItem(title: "Emotions", value: emotion.rawValue.capitalized, icon: emotion.image))
        }
        if let intensity = review.intensity {
            items.append(SummaryItem(title: "Emotional Intensity", value: Self.intensityLabel(intensity)))
        }
        let journal = review.journal.trimmingCharacters(in: .whitespacesAndNewlines)
        if !journal.isEmpty {
            items.append(SummaryItem(title: "Emotion Journal", value: journal))
        }
        // One card per program journal; numbered when a day has more than one.
        let workoutJournals = review.workoutJournals.values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted()
        for (index, text) in workoutJournals.enumerated() {
            let title = workoutJournals.count > 1 ? "Workout Journal \(index + 1)" : "Workout Journal"
            items.append(SummaryItem(title: title, value: text))
        }
        return items
    }

    var body: some View {
        let items = items
        VStack(alignment: .leading, spacing: 12) {
            if items.isEmpty {
                Text("Nothing logged yet - tap the pencil to add your review")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(CoreColor.primary.opacity(0.7))
            }

            ForEach(showAll ? items : Array(items.prefix(previewCount))) { item in
                card(item)
            }

            if items.count > previewCount {
                Button {
                    withAnimation(.snappy) { showAll.toggle() }
                } label: {
                    Text(showAll ? "View Less" : "View More")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(CoreColor.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func card(_ item: SummaryItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(CoreColor.secondary)

            HStack(spacing: 8) {
                if let icon = item.icon {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(item.value)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(CoreColor.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CoreColor.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// Words for the 0...4 slider, matching its VERY UNPLEASANT ... VERY PLEASANT ends.
    private static func intensityLabel(_ value: Int) -> String {
        switch value {
        case ...0: "Very unpleasant"
        case 1: "Unpleasant"
        case 2: "Moderate"
        case 3: "Pleasant"
        default: "Very pleasant"
        }
    }
}

private struct SummaryItem: Identifiable {
    let title: String
    let value: String
    var icon: ImageResource?

    var id: String { title }
}

#Preview {
    var review = PollAnswers(date: .now)
    review.setAnswer(.yes, for: .trained)
    review.setAnswer(.no, for: .onPeriod)
    review.emotion = .calm
    review.intensity = 2
    review.journal = "Felt strong in the second half."
    return ReviewSummaryView(review: review)
        .padding()
}

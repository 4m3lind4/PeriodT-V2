//
//  DayDetailSheet.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Sheet shown when a calendar day is tapped. Opens on an overview of that day
/// (cycle phase, workout, logged review); the pencil switches to the review form.
struct DayDetailSheet: View {
    let day: Date

    @EnvironmentObject private var store: TrackingStore
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var expandedProgramID: ExerciseProgram.ID?

    private var review: PollAnswers? { store.review(for: day) }
    private var programs: [ExerciseProgram] { store.programs(on: day) }
    private var phase: CyclePhase? { CyclePhase.phase(on: day, from: store.allReviews) }

    var body: some View {
        ScrollView {
            Group {
                if isEditing {
                    editor
                } else {
                    overview
                }
            }
            .padding()
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        // Sheets sit above the calendar's host, so errors need their own.
        .errorCardHost()
        .presentationDetents([.fraction(0.8), .large])
        .presentationDragIndicator(.visible)
        // White like the design, so the pale pink cards stand out.
        .presentationBackground(Color.white.opacity(0.95))
    }

    // MARK: - Overview

    private var overview: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 6) {
                // "Friday 7 of September"
                Text("\(day.formatted(.dateTime.weekday(.wide))) \(day.formatted(.dateTime.day())) of \(day.formatted(.dateTime.month(.wide)))")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(CoreColor.primary)
                    .multilineTextAlignment(.center)

                if let phase {
                    Text("You are in your")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(CoreColor.primary)
                    Text("\(phase.rawValue) Phase")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 6)
                        .background(CoreColor.primary, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 2) {
                sectionTitle("My Programs")
                Text("Exercise programs")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(CoreColor.primary)
            }

            if programs.isEmpty {
                Text("No program scheduled")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(CoreColor.primary.opacity(0.7))
            } else {
                ForEach(programs) { program in
                    ExpandableProgramCard(program: program,
                                          expandedProgramID: $expandedProgramID,
                                          showsStart: false)
                }
            }

            HStack {
                sectionTitle("Review")
                Spacer()
                Button {
                    withAnimation(.snappy) { isEditing = true }
                } label: {
                    // Plus when nothing is logged yet, pencil to edit an existing review.
                    Image(systemName: review == nil ? "plus" : "pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CoreColor.primary)
                        .frame(width: 44, height: 44)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .accessibilityLabel(review == nil ? "Add review" : "Edit review")
            }

            if let review {
                ReviewSummaryView(review: review)
            } else {
                Text("No review logged for this day")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(CoreColor.primary.opacity(0.7))
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(CoreColor.primary, in: RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityLabel("Close")
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    // MARK: - Editor

    /// The same form as Home's Review. Answers save as they change, so Submit
    /// just returns to the overview.
    private var editor: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(CoreColor.primary)

            sectionTitle("Review")

            DayPollView(day: day)

            Button {
                withAnimation(.snappy) { isEditing = false }
            } label: {
                PrimaryButtonLabel(title: "Submit", style: .filled)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(CoreColor.primary)
    }
}

#Preview {
    Color.white
        .sheet(isPresented: .constant(true)) {
            DayDetailSheet(day: .now)
        }
        .previewTrackingStore()
}

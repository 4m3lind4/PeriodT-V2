//
//  JournalEntrySheet.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI

/// "Entries" sheet opened from the Journal page. The tag dropdown picks which of
/// the day's journals the text box edits: Emotional, or the Workout journal of
/// one program (`programID`, else the day's first program).
struct JournalEntrySheet: View {
    let day: Date
    private let programID: UUID?

    init(day: Date, initialType: JournalType = .emotional, programID: UUID? = nil) {
        self.day = day
        self.programID = programID
        _type = State(initialValue: initialType)
    }

    @EnvironmentObject private var store: TrackingStore
    @Environment(\.presentError) private var presentError

    @State private var draft = ""
    @State private var type: JournalType
    @State private var isEditingReview = false
    @FocusState private var isTyping: Bool

    private var review: PollAnswers? { store.review(for: day) }

    /// The program whose workout journal this sheet edits.
    private var workoutProgramID: UUID? { programID ?? store.programs(on: day).first?.id }

    /// Workout journals belong to a program, so there's nothing to save without one.
    private var canSave: Bool { type == .emotional || workoutProgramID != nil }

    private func journalText(for type: JournalType) -> String {
        switch type {
        case .emotional: review?.journal ?? ""
        case .workout: workoutProgramID.flatMap { review?.workoutJournal(for: $0) } ?? ""
        }
    }
    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Date")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Spacer()
                        Text(day, format: .dateTime.day(.twoDigits).month(.twoDigits).year(.twoDigits))
                            .font(.system(size: 20, design: .rounded))
                    }
                    .foregroundStyle(CoreColor.ringBackground)

                    detailsBox

                    Button(action: save) {
                        PrimaryButtonLabel(title: "Save")
                    }
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                    .frame(maxWidth: .infinity)

                    reviewSection
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
            .background(CoreColor.primary)
        }
        .background(Color.white)
        .errorCardHost()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { draft = journalText(for: type) }
        // Switching tag shows the other journal for this day.
        .onChange(of: type) { _, newType in draft = journalText(for: newType) }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Entries")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(CoreColor.primary)
            Spacer()
            Menu {
                Picker("Journal type", selection: $type) {
                    ForEach(JournalType.allCases) { option in
                        // Menus tint SF Symbols with the accent colour, so bake each dot's colour in.
                        Label {
                            Text(option.title)
                        } icon: {
                            Image(uiImage: UIImage(systemName: "circle.fill")!
                                .withTintColor(UIColor(option.color), renderingMode: .alwaysOriginal))
                        }
                        .tag(option)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Circle().fill(type.color).frame(width: 10, height: 10)
                    Text(type.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Image(systemName: "tag")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(type.color)
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(.white, in: Capsule())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .accessibilityLabel("Journal type, \(type.title)")
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

    // MARK: - Details

    private var detailsBox: some View {
        ZStack {
            if draft.isEmpty && !isTyping {
                Text(canSave ? "Tap to add details" : "No program on this day")
                    .font(.system(size: 20, design: .rounded))
                    .foregroundStyle(CoreColor.primary)
            }
            TextEditor(text: $draft)
                .focused($isTyping)
                .scrollContentBackground(.hidden)
                .font(.system(size: 18, design: .rounded))
                .foregroundStyle(CoreColor.primary)
                .padding(12)
        }
        .frame(height: 250)
        .background(CoreColor.ringBackground, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
    }

    private func save() {
        isTyping = false
        let text = draft
        let type = type
        let programID = workoutProgramID
        store.update(day, onFailure: { presentError(.saveFailed(.journal)) }) {
            switch type {
            case .emotional: $0.journal = text
            case .workout: if let programID { $0.setWorkoutJournal(text, for: programID) }
            }
        }
    }

    // MARK: - Review

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Review")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(CoreColor.ringBackground)
                Spacer()
                Button {
                    withAnimation(.snappy) { isEditingReview.toggle() }
                } label: {
                    Image(systemName: isEditingReview ? "checkmark" : (review == nil ? "plus" : "pencil"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(CoreColor.primary)
                        .frame(width: 44, height: 44)
                        .background(.white, in: Circle())
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                }
                .accessibilityLabel(isEditingReview ? "Done" : (review == nil ? "Add review" : "Edit review"))
            }

            if isEditingReview {
                DayPollView(day: day)
            } else if let review {
                ReviewSummaryView(review: review)
            }
        }
    }
}

#Preview {
    Color.white
        .sheet(isPresented: .constant(true)) {
            JournalEntrySheet(day: .now)
        }
        .previewTrackingStore()
}

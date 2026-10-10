//
//  PeriodTJournal.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 9/10/2026.
//

import SwiftUI

/// Journal tab: the user's goals, then their journal entries newest first.
/// Each day can have two entries: Home's emotional journal and the workout journal.
struct PeriodTJournal: View {
    @EnvironmentObject private var store: TrackingStore

    /// Goals aren't stored anywhere yet, so they only last until the app quits.
    @State private var goals: [JournalGoal] = JournalGoal.samples
    @State private var expandedGoalID: JournalGoal.ID?
    @State private var showAllGoals = false
    @State private var showAllEntries = false

    @State private var isAddingGoal = false
    @State private var newGoalText = ""
    @State private var openEntry: JournalEntry?

    /// Items shown per section before "View More".
    private let previewCount = 2

    /// Every non-empty journal, most recent first; workout entries before emotional on the same day.
    private var entries: [JournalEntry] {
        let all: [JournalEntry] = store.allReviews.flatMap(entries(in:))
        return all.sorted { lhs, rhs in
            lhs.date != rhs.date ? lhs.date > rhs.date : lhs.type == .workout && rhs.type != .workout
        }
    }

    /// The day's emotional journal plus one entry per program journal.
    private func entries(in review: PollAnswers) -> [JournalEntry] {
        var result: [JournalEntry] = []
        for (programID, text) in review.workoutJournals where !Self.isBlank(text) {
            let program = store.programs.first { $0.id == programID }
            result.append(JournalEntry(date: review.date, type: .workout, text: text,
                                       programID: programID,
                                       programTitle: program.map { "\($0.exerciseType.title) Day \($0.day)" }))
        }
        if !Self.isBlank(review.journal) {
            result.append(JournalEntry(date: review.date, type: .emotional, text: review.journal,
                                       emotion: review.emotion))
        }
        return result
    }

    private static func isBlank(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Journal")

                sectionTitle("Goals")
                AddCircleButton(label: "Add new goal") { isAddingGoal = true }

                ForEach(Array((showAllGoals ? goals : Array(goals.prefix(previewCount))).enumerated()),
                        id: \.element.id) { index, goal in
                    GoalCard(goal: goal, number: index + 1, expandedGoalID: $expandedGoalID)
                }
                if goals.count > previewCount {
                    viewMoreButton(isOn: $showAllGoals)
                }

                sectionTitle("Entries")
                    .padding(.top, 8)
                AddCircleButton(label: "Add new entry") {
                    openEntry = JournalEntry(date: Date().startOfDay, type: .emotional, text: "")
                }

                if entries.isEmpty {
                    Text("No entries yet")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(CoreColor.primary.opacity(0.7))
                }
                ForEach(showAllEntries ? entries : Array(entries.prefix(previewCount)), id: \.id) { entry in
                    JournalEntryCard(entry: entry)
                        .onTapGesture { openEntry = entry }
                }
                if entries.count > previewCount {
                    viewMoreButton(isOn: $showAllEntries)
                }
            }
            .padding(16)
        }
        // Keeps the last card clear of the tab bar.
        .contentMargins(.bottom, 100, for: .scrollContent)
        .background(Color.white.ignoresSafeArea())
        .sheet(item: $openEntry) { entry in
            JournalEntrySheet(day: entry.date, initialType: entry.type, programID: entry.programID)
        }
        .alert("New goal", isPresented: $isAddingGoal) {
            TextField("e.g. Stretch every morning", text: $newGoalText)
            Button("Add") { addGoal() }
            Button("Cancel", role: .cancel) { newGoalText = "" }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(CoreColor.primary)
    }

    private func viewMoreButton(isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(.snappy) { isOn.wrappedValue.toggle() }
        } label: {
            Text(isOn.wrappedValue ? "View Less" : "View More")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(CoreColor.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func addGoal() {
        let text = newGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        newGoalText = ""
        guard !text.isEmpty else { return }
        goals.append(JournalGoal(detail: text))
    }
}

// MARK: - Goals

struct JournalGoal: Identifiable, Hashable {
    let id = UUID()
    let detail: String

    static let samples = [
        JournalGoal(detail: "Complete physio exercises for hip improvement"),
        JournalGoal(detail: "Train at least 3 times a week"),
        JournalGoal(detail: "Log my mood every day this month")
    ]
}

/// "GOAL n" card; tapping it reveals the full goal text.
private struct GoalCard: View {
    let goal: JournalGoal
    let number: Int
    @Binding var expandedGoalID: JournalGoal.ID?

    private var isExpanded: Bool { expandedGoalID == goal.id }

    var body: some View {
        Button {
            withAnimation(.snappy) { expandedGoalID = isExpanded ? nil : goal.id }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GOAL \(number)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(goal.detail)
                        .font(.system(size: 14, design: .rounded))
                        .lineLimit(isExpanded ? nil : 1)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 22))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .foregroundStyle(CoreColor.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(CoreColor.ringBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Entries

/// One journal (emotional or workout) for one day.
struct JournalEntry: Identifiable {
    let date: Date
    let type: JournalType
    let text: String
    var emotion: Emotion?
    /// Set for workout entries: which program the journal belongs to.
    var programID: UUID?
    var programTitle: String?

    var id: String { "\(date.timeIntervalSince1970)-\(type.rawValue)-\(programID?.uuidString ?? "")" }
}

/// Date and tags above a card with the mood as title and a one-line preview.
private struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(entry.date.formatted(.dateTime.day())) of \(entry.date.formatted(.dateTime.month(.wide)))")
                    .font(.system(size: 20, design: .rounded))
                Spacer()
                // Pink for workout journals, orange for emotional ones.
                tag(entry.type.title, color: entry.type.color)
            }
            .foregroundStyle(CoreColor.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.emotion?.rawValue.capitalized ?? entry.programTitle ?? "\(entry.type.title) Journal")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(entry.text)
                    .font(.system(size: 18, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(CoreColor.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(CoreColor.ringBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .contentShape(Rectangle())
    }

    private func tag(_ title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 12, height: 12)
            Text(title).font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.leading, 8)
    }
}

// MARK: - Shared pieces

/// White circular "+" with a caption underneath.
private struct AddCircleButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(CoreColor.primary)
                    .frame(width: 96, height: 96)
                    .background(Circle().fill(.white))
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
                Text(label)
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundStyle(CoreColor.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PeriodTJournal()
        .errorCardHost()
        .previewTrackingStore()
}

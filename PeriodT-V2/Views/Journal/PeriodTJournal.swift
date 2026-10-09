//
//  PeriodTJournal.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 9/10/2026.
//

import SwiftUI

/// Journal tab: the user's goals, then their journal entries newest first.
/// Entries are the daily reviews (from `TrackingStore`) that have journal text.
struct PeriodTJournal: View {
    @EnvironmentObject private var store: TrackingStore

    /// Goals aren't stored anywhere yet, so they only last until the app quits.
    @State private var goals: [JournalGoal] = JournalGoal.samples
    @State private var expandedGoalID: JournalGoal.ID?
    @State private var showAllGoals = false
    @State private var showAllEntries = false

    @State private var isAddingGoal = false
    @State private var newGoalText = ""
    @State private var entryDay: SelectedDay?

    /// Items shown per section before "View More".
    private let previewCount = 2

    /// Days with journal text, most recent first.
    private var entries: [PollAnswers] {
        store.allReviews
            .filter { !$0.journal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { $0.date > $1.date }
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
                // Journal text lives on the daily review, so a new entry is today's review.
                AddCircleButton(label: "Add new entry") {
                    entryDay = SelectedDay(id: Date().startOfDay)
                }

                if entries.isEmpty {
                    Text("No entries yet")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(CoreColor.primary.opacity(0.7))
                }
                ForEach(showAllEntries ? entries : Array(entries.prefix(previewCount)), id: \.date) { entry in
                    JournalEntryCard(entry: entry)
                        .onTapGesture { entryDay = SelectedDay(id: entry.date) }
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
        .sheet(item: $entryDay) { selected in
            DayDetailSheet(day: selected.date)
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

/// Date and tags above a card with the mood as title and a one-line preview.
private struct JournalEntryCard: View {
    let entry: PollAnswers

    private var trained: Bool { entry.answers[.trained] == .yes }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(entry.date.formatted(.dateTime.day())) of \(entry.date.formatted(.dateTime.month(.wide)))")
                    .font(.system(size: 20, design: .rounded))
                Spacer()
                if trained { tag("Workout", color: CoreColor.primary) }
                if entry.emotion != nil { tag("Emotional", color: CoreColor.accent) }
            }
            .foregroundStyle(CoreColor.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.emotion?.rawValue.capitalized ?? "Journal")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text(entry.journal)
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

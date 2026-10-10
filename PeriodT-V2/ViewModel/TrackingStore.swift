//
//  TrackingStore.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 9/10/2026.
//

import Foundation
import SwiftUI
import Combine
import OSLog

/// App-wide cache of the user's daily reviews, backed by Supabase.
/// Home, the calendar and the day sheet all read from here, so an edit in
/// one place shows up everywhere straight away.
@MainActor
final class TrackingStore: ObservableObject {
    private static let logger = Logger(subsystem: "PeriodT", category: "TrackingStore")

    /// Keyed by `startOfDay`.
    @Published private(set) var reviews: [Date: PollAnswers] = [:]
    /// Days with a program that has at least one ticked workout (calendar dots).
    @Published private(set) var completedProgramDays: Set<Date> = []
    /// Every program the user can see, for showing a day's workout in the calendar sheet.
    @Published private(set) var programs: [ExerciseProgram] = []

    private let repository: IPeriodTRepository
    /// One pending save per day; a new edit restarts that day's wait.
    private var pendingSaves: [Date: Task<Void, Never>] = [:]
    /// Wait before saving, so typing and slider drags send one request, not dozens.
    private let saveDelay: Duration = .milliseconds(600)

    init(repository: IPeriodTRepository) {
        self.repository = repository
    }

    var allReviews: [PollAnswers] { Array(reviews.values) }

    func review(for day: Date) -> PollAnswers? {
        reviews[day.startOfDay]
    }

    func programs(on day: Date) -> [ExerciseProgram] {
        programs.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    /// Fetches reviews and program completions. Failures are logged and leave
    /// the current values in place.
    func load() async {
        do {
            let fetched = try await repository.fetchPollAnswers()
            reviews = Dictionary(fetched.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
        } catch {
            Self.logger.error("Failed to load reviews: \(error.localizedDescription)")
        }
        do {
            let programs = try await repository.fetchWorkouts()
            self.programs = programs
            completedProgramDays = Set(programs
                .filter { $0.workouts.contains(where: \.isCompleted) }
                .map { $0.date.startOfDay })
        } catch {
            Self.logger.error("Failed to load program completions: \(error.localizedDescription)")
        }
    }

    /// Applies `mutate` locally right away, then saves to Supabase after a short pause.
    /// `onFailure` runs if that save fails.
    func update(_ day: Date,
                onFailure: @escaping () -> Void,
                _ mutate: (inout PollAnswers) -> Void) {
        let key = day.startOfDay
        var review = reviews[key] ?? PollAnswers(date: key)
        mutate(&review)
        reviews[key] = review

        pendingSaves[key]?.cancel()
        pendingSaves[key] = Task { [repository, saveDelay] in
            try? await Task.sleep(for: saveDelay)
            guard !Task.isCancelled else { return }
            do {
                // Save whatever is latest by now, not the snapshot from this edit.
                if let latest = self.reviews[key] {
                    try await repository.savePollAnswers(latest)
                }
            } catch {
                Self.logger.error("Failed to save review for \(key): \(error.localizedDescription)")
                onFailure()
            }
        }
    }
}

// MARK: - Previews

/// Gives a preview a `TrackingStore` filled from `MockPeriodTRepository`.
/// The store only fills once `load()` runs, which the app does in `ContentView`.
private struct PreviewTrackingStore: ViewModifier {
    @StateObject private var store = TrackingStore(repository: MockPeriodTRepository())

    func body(content: Content) -> some View {
        content
            .environmentObject(store)
            .task { await store.load() }
    }
}

extension View {
    func previewTrackingStore() -> some View {
        modifier(PreviewTrackingStore())
    }
}

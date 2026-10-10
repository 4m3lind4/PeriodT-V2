//
//  TrackingStore.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 9/10/2026.
//
//  The single source of truth for the athlete's daily check-ins. Home, the
//  calendar and the day sheet all read from here, so editing a day in one place
//  shows up everywhere straight away. Edits apply locally first and save to
//  Supabase in the background, which keeps the UI feeling instant.
//

import Foundation
import SwiftUI
import Combine
import OSLog
import WidgetKit

@MainActor
final class TrackingStore: ObservableObject {
    private static let logger = Logger(subsystem: "PeriodT", category: "TrackingStore")

    /// Keyed by `startOfDay`.
    @Published private(set) var reviews: [Date: PollAnswers] = [:] {
        didSet { syncPeriodWidget() }
    }
    /// Days with at least one ticked workout, for the dots on the calendar.
    @Published private(set) var completedProgramDays: Set<Date> = []
    /// Every program the athlete can see, so the calendar sheet can show a day's workout.
    @Published private(set) var programs: [ExerciseProgram] = []

    private let repository: IPeriodTRepository
    /// One pending save per day, and a new edit restarts that day's wait. A day stays
    /// in here until its save finishes, so `load()` knows not to overwrite it.
    private var pendingSaves: [Date: Task<Void, Never>] = [:]
    /// Which edit owns each day's save, so an older save finishing late doesn't
    /// clear out the entry for a newer one.
    private var pendingSaveIDs: [Date: UUID] = [:]
    /// How long to wait before saving, so typing or dragging a slider sends one request instead of dozens.
    private let saveDelay: Duration

    init(repository: IPeriodTRepository, saveDelay: Duration = .milliseconds(600)) {
        self.repository = repository
        self.saveDelay = saveDelay
    }

    var allReviews: [PollAnswers] { Array(reviews.values) }

    func review(for day: Date) -> PollAnswers? {
        reviews[day.startOfDay]
    }

    func programs(on day: Date) -> [ExerciseProgram] {
        programs.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    /// Pulls down reviews and program completions. If either fails it's logged and
    /// whatever we already had stays put. Days with an unsaved edit keep the local
    /// copy, since the server's version is older.
    func load() async {
        do {
            let fetched = try await repository.fetchPollAnswers()
            var loaded = Dictionary(fetched.map { ($0.date, $0) }, uniquingKeysWith: { first, _ in first })
            for key in pendingSaves.keys {
                loaded[key] = reviews[key]
            }
            reviews = loaded
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

    /// Applies the change locally straight away, then saves to Supabase after a short
    /// pause. This debounce is what lets the check-in feel instant while still only
    /// sending one request per burst of edits. `onFailure` runs if the save fails.
    func update(_ day: Date,
                onFailure: @escaping () -> Void,
                _ mutate: (inout PollAnswers) -> Void) {
        let key = day.startOfDay
        var review = reviews[key] ?? PollAnswers(date: key)
        mutate(&review)
        reviews[key] = review

        pendingSaves[key]?.cancel()
        let saveID = UUID()
        pendingSaveIDs[key] = saveID
        pendingSaves[key] = Task { [repository, saveDelay] in
            try? await Task.sleep(for: saveDelay)
            // A newer edit took over this save and will clean up after itself.
            guard !Task.isCancelled else { return }
            defer { self.finishSave(for: key, id: saveID) }
            do {
                // Save whatever's latest by now, not the snapshot from when this edit happened.
                if let latest = self.reviews[key] {
                    try await repository.savePollAnswers(latest)
                }
            } catch {
                // Cancelled mid-request by a newer edit, which will do its own save.
                guard !Task.isCancelled else { return }
                Self.logger.error("Failed to save review for \(key): \(error.localizedDescription)")
                onFailure()
            }
        }
    }

    private func finishSave(for key: Date, id: UUID) {
        guard pendingSaveIDs[key] == id else { return }
        pendingSaveIDs[key] = nil
        pendingSaves[key] = nil
    }

    /// Hands the latest period start to the widget so its countdown stays up to date.
    private func syncPeriodWidget() {
        let periodDue = PeriodDueViewModel()
        let changed = PeriodCountdownStore.save(lastPeriod: periodDue.lastPeriodStart(in: allReviews),
                                                cycleLength: periodDue.cycleLength)
        if changed {
            WidgetCenter.shared.reloadTimelines(ofKind: PeriodCountdownStore.widgetKind)
        }
    }
}

// MARK: - Previews

/// Gives a preview a `TrackingStore` filled from `MockPeriodTRepository`. In the real
/// app `ContentView` calls `load()`, so previews need to do it themselves.
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

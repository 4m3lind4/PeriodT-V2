//
//  ContentView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import Combine
import SwiftUI

/// Root of the app: a three-tab layout (Home, Calendar, Exercise).
/// Tab selection and the exercise navigation stack live in `AppNavigationViewModel`
/// so deep screens (e.g. the completed-program page) can jump back home.
struct ContentView: View {
    let repository: IPeriodTRepository

    @EnvironmentObject private var navigation: AppNavigationViewModel
    @EnvironmentObject private var store: TrackingStore
    @ObservedObject private var notificationRouter = NotificationRouter.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            // Placeholder Home until a dedicated home screen is ported.
            // PeriodTHome scrolls itself (so its Submit can jump back to the top).
            PeriodTHome(repository: repository)
                .padding(.horizontal)
                .errorCardHost()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Home")
                }
                .tag(AppNavigationViewModel.Tab.home)

            PeriodTTracking()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(AppNavigationViewModel.Tab.calendar)

            // PeriodTExercises owns its NavigationStack (bound to navigation.exercisePath).
            PeriodTExercises(repository: repository)
                .errorCardHost()
                .tabItem {
                    Image(systemName: "figure.flexibility")
                    Text("Exercise")
                }
                .tag(AppNavigationViewModel.Tab.exercise)
            
            PeriodTJournal()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Journal")
                }
                .tag(AppNavigationViewModel.Tab.journal)
        }
        .tint(CoreColor.primary)
        // Load first so the first schedule knows which days are already checked in.
        // On first launch requestPermissionIfNeeded shows the system prompt.
        .task {
            await store.load()
            await NotificationManager.shared.requestPermissionIfNeeded()
            await rescheduleNotifications()
        }
        // Rebuild notifications when a period, check-in or program changes.
        // The short wait lets the burst of edits (and the first load) settle.
        .task(id: NotificationPlanner.Inputs(reviews: store.allReviews, programs: store.programs)) {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await rescheduleNotifications()
        }
        // Dates move on overnight, so top the plan up whenever the app comes back.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await rescheduleNotifications() }
            }
        }
        // Ticking workouts changes the calendar dots, so refresh on leaving Exercise.
        .onChange(of: navigation.selectedTab) { _, _ in
            Task { await store.load() }
        }
        // A tapped notification opens its tab.
        .onReceive(notificationRouter.$pendingTab.compactMap { $0 }) { tab in
            navigation.selectedTab = tab
            notificationRouter.pendingTab = nil
        }
    }

    private func rescheduleNotifications() async {
        await NotificationScheduler.shared.reschedule(reviews: store.allReviews, programs: store.programs)
    }
}

#Preview {
    ContentView(repository: MockPeriodTRepository())
        .environmentObject(AppNavigationViewModel())
        .previewTrackingStore()
}

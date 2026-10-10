//
//  ContentView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//
//  The root view. Holds the four tabs and does the app-wide jobs that don't
//  belong to any one screen: loading the store, keeping notifications up to date
//  and opening the right tab when a notification is tapped.
//

import Combine
import SwiftUI

struct ContentView: View {
    let repository: IPeriodTRepository

    @EnvironmentObject private var navigation: AppNavigationViewModel
    @EnvironmentObject private var store: TrackingStore
    @ObservedObject private var notificationRouter = NotificationRouter.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            // PeriodTHome handles its own scrolling so Submit can jump back to the top.
            PeriodTHome()
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

            // PeriodTExercises owns its NavigationStack, bound to navigation.exercisePath.
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
        // Load the data before scheduling anything, otherwise the first round of
        // notifications wouldn't know which days are already checked in.
        .task {
            await store.load()
            await NotificationManager.shared.requestPermissionIfNeeded()
            await rescheduleNotifications()
        }
        // Rebuild notifications whenever a period, check-in or program changes. The
        // one second wait lets a burst of edits settle so we only reschedule once.
        .task(id: NotificationPlanner.Inputs(reviews: store.allReviews, programs: store.programs)) {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            await rescheduleNotifications()
        }
        // Dates move on overnight, so top the plan up whenever the app is reopened.
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await rescheduleNotifications() }
            }
        }
        // Ticking workouts changes the calendar dots, so refresh when switching tabs.
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

//
//  ContentView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import SwiftUI

/// Root of the app: a three-tab layout (Home, Calendar, Exercise).
/// Tab selection and the exercise navigation stack live in `AppNavigationViewModel`
/// so deep screens (e.g. the completed-program page) can jump back home.
struct ContentView: View {
    let repository: IPeriodTRepository

    @EnvironmentObject private var navigation: AppNavigationViewModel
    @EnvironmentObject private var store: TrackingStore

    var body: some View {
        //MARK: TESTING NOTIFICATION
        VStack{
            Button("Test Phase Notification") {
                Task {
                    let granted = await NotificationManager.shared
                        .requestPermission()

                    if granted {
                        await CycleNotification.shared
                            .schedulePhaseNotification(for: store.allReviews)
                    } else {
                        print("Notifications not authorised")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
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
        .task { await store.load() }
        // Ticking workouts changes the calendar dots, so refresh on leaving Exercise.
        .onChange(of: navigation.selectedTab) { _, _ in
            Task { await store.load() }
        }
    }
}

#Preview {
    ContentView(repository: MockPeriodTRepository())
        .environmentObject(AppNavigationViewModel())
        .previewTrackingStore()
}

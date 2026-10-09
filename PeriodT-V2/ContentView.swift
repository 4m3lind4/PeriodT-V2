//
//  ContentView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import SwiftUI
import SwiftData

/// Root of the app: a three-tab layout (Home, Calendar, Exercise).
/// Tab selection and the exercise navigation stack live in `AppNavigationViewModel`
/// so deep screens (e.g. the completed-program page) can jump back home.
struct ContentView: View {
    let repository: IPeriodTRepository

    @EnvironmentObject private var navigation: AppNavigationViewModel

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            // Placeholder Home until a dedicated home screen is ported.
            ScrollView {
                HomeQuestionaireView()
                    .padding()
            }
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
        }
        .tint(CoreColor.primary)
    }
}

#Preview {
    ContentView(repository: MockPeriodTRepository())
        .environmentObject(AppNavigationViewModel())
        .modelContainer(for: [PollAnswers.self, CompletedProgram.self], inMemory: true)
}

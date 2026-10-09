//
//  PeriodT_V2App.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import SwiftUI
import SwiftData

@main
struct PeriodT_V2App: App {

    private let repository: IPeriodTRepository = PeriodTRepository(projectURL: URL(string: "https://mizilxflvxuldksvcvhz.supabase.co")!, publishableKey: "sb_publishable_D12Dbrz6AttqLF-p73xJcA_3Jov0JJx")

    // Created once for the app's lifetime; @StateObject stops it being rebuilt on redraw.
    @StateObject private var navigation = AppNavigationViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
                // App-wide errors sit above the tab bar.
                .errorCardHost()
                .environmentObject(navigation)
        }
        // Calendar and Home polls read/write these via SwiftData.
        .modelContainer(for: [PollAnswers.self, CompletedProgram.self])
    }
}

//
//  NotificationRouter.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Passes the tab from a tapped notification over to the UI.
//

import Combine
import Foundation

/// The app delegate can get the tap before any view exists (e.g. on a cold launch),
/// so the tab waits here until `ContentView` is ready to pick it up.
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()

    @Published var pendingTab: AppNavigationViewModel.Tab?

    private init() {}
}

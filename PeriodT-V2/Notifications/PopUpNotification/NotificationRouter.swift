//
//  NotificationRouter.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Combine
import Foundation

/// Hands the tab from a tapped notification to the UI. The app delegate can
/// receive the tap before any view exists, so the tab waits here until
/// `ContentView` picks it up.
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()

    @Published var pendingTab: AppNavigationViewModel.Tab?

    private init() {}
}

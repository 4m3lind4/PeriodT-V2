//
//  AppNavigationViewModel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  Shared navigation state (the selected tab and the exercise stack). I pulled
//  this out of the views so a screen deep in the exercise flow can send the user
//  back to Home without passing callbacks through every level.
//

import Foundation
import Combine
import SwiftUI

final class AppNavigationViewModel: ObservableObject {
    enum Tab: Int {
        case home, calendar, exercise, journal
    }

    @Published var selectedTab: Tab = .home
    @Published var exercisePath = NavigationPath()

    /// Clears the exercise stack and returns to the Home tab.
    func returnHome() {
        exercisePath = NavigationPath()
        selectedTab = .home
    }
}

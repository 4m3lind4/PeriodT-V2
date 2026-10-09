//
//  PeriodT_V2App.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import SwiftUI
import UserNotifications

/// Lets notifications show as banners even when the app is open.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}

@main
struct PeriodT_V2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let repository: IPeriodTRepository


    // Created once for the app's lifetime; @StateObject stops it being rebuilt on redraw.
    @StateObject private var navigation = AppNavigationViewModel()
    @StateObject private var store: TrackingStore

    init() {
        let repository: IPeriodTRepository = PeriodTRepository(projectURL: URL(string: "https://mizilxflvxuldksvcvhz.supabase.co")!, publishableKey: "sb_publishable_D12Dbrz6AttqLF-p73xJcA_3Jov0JJx")
        self.repository = repository
        _store = StateObject(wrappedValue: TrackingStore(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
                // App-wide errors sit above the tab bar.
                .errorCardHost()
                .environmentObject(navigation)
                .environmentObject(store)
        }
    }
}

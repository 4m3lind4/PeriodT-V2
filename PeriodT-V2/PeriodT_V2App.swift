//
//  PeriodT_V2App.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//
//  App entry point. This is where the repository gets picked (Supabase normally,
//  the mock one for UI tests) and handed down to everything else, so no view ever
//  creates its own database connection.
//

import SwiftUI
import UserNotifications

/// Lets notifications show as banners even while the app is open, and opens
/// the matching tab when one is tapped.
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

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        if let rawTab = userInfo[NotificationScheduler.tabKey] as? Int,
           let tab = AppNavigationViewModel.Tab(rawValue: rawTab) {
            NotificationRouter.shared.pendingTab = tab
        }
    }
}

@main
struct PeriodT_V2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let repository: IPeriodTRepository


    // @StateObject so these are made once and survive every redraw.
    @StateObject private var navigation = AppNavigationViewModel()
    @StateObject private var store: TrackingStore

    init() {
        let repository = Self.makeRepository()
        self.repository = repository
        _store = StateObject(wrappedValue: TrackingStore(repository: repository))
    }

    /// UI tests launch with `-UITesting` to use `MockPeriodTRepository` instead of Supabase,
    /// and add `-UITestingOffline` to make every call fail so the error states can be tested.
    private static func makeRepository() -> IPeriodTRepository {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-UITesting") {
            return MockPeriodTRepository(shouldFail: arguments.contains("-UITestingOffline"))
        }
        #endif
        return PeriodTRepository(projectURL: URL(string: "https://mizilxflvxuldksvcvhz.supabase.co")!, publishableKey: "sb_publishable_D12Dbrz6AttqLF-p73xJcA_3Jov0JJx")
    }

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
                // App-wide errors show above the tab bar.
                .errorCardHost()
                .environmentObject(navigation)
                .environmentObject(store)
        }
    }
}

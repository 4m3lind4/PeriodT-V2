//
//  NotificationManager.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import OSLog
import UserNotifications

/// Owns notification permission. iOS only shows the system prompt once,
/// so after that we can only read the user's choice.
final class NotificationManager {

    static let shared = NotificationManager()

    private static let logger = Logger(subsystem: "PeriodT", category: "Notifications")

    private init() {}

    /// The user's current choice (not asked yet, allowed, denied, …).
    func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Whether we're currently allowed to send notifications.
    func isAuthorized() async -> Bool {
        switch await authorizationStatus() {
        case .authorized, .provisional, .ephemeral: true
        default: false
        }
    }

    /// Shows the system prompt if the user hasn't been asked yet.
    /// Returns whether we're allowed to send notifications.
    @discardableResult
    func requestPermissionIfNeeded() async -> Bool {
        guard await authorizationStatus() == .notDetermined else { return await isAuthorized() }
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            Self.logger.error("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }
}

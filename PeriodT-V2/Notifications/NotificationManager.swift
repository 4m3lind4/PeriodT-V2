//
//  NotificationManager.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    // Request permission to send notifications
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])

            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
}



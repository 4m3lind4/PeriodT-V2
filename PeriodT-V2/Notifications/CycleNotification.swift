//
//  PeriodTNotification.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//


import Foundation
import UserNotifications

final class CycleNotification{

    static let shared = CycleNotification()

    private init() {}

    func scheduleLutealNotification() async {

        // 1. Create notification content
        let content = UNMutableNotificationContent()

        content.title = "PeriodT"
        content.body = "You're entering your Luteal Phase 🌙"
        content.sound = .default

        // 2. Set notification timing
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        // 3. Create notification request
        let request = UNNotificationRequest(
            identifier: "lutealPhaseNotification",
            content: content,
            trigger: trigger
        )

        // 4. Schedule the notification
        do {
            try await UNUserNotificationCenter.current()
                .add(request)

            print("Luteal notification scheduled!")
        } catch {
            print("Notification error: \(error)")
        }
    }
}

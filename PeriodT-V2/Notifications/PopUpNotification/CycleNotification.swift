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

    /// Sends a pop-up telling the user which phase they're in.
    /// If no period has been logged, it asks them to log one instead.
    func schedulePhaseNotification(for answers: [PollAnswers]) async {
        let content = UNMutableNotificationContent()
        content.title = "PeriodT"
        content.sound = .default

        if let phase = CyclePhase.current(from: answers) {
            content.body = phase.message
        } else {
            content.body = "Log your period so we can tell you what phase you're in 💗"
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "cyclePhaseNotification",
                                            content: content,
                                            trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Notification error: \(error)")
        }
    }
}


func scheduleLutealNotification(
    on lutealStartDate: Date
) async {

    let content = UNMutableNotificationContent()
    content.title = "PeriodT"
    content.body = "You're entering your Luteal Phase 🌙"
    content.sound = .default

    // Create a calendar-based trigger
    let components = Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: lutealStartDate
    )

    let trigger = UNCalendarNotificationTrigger(
        dateMatching: components,
        repeats: false
    )

    let request = UNNotificationRequest(
        identifier: "lutealPhaseNotification",
        content: content,
        trigger: trigger
    )

    do {
        try await UNUserNotificationCenter.current()
            .add(request)
    } catch {
        print("Scheduling failed: \(error)")
    }
}



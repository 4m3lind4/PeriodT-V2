//
//  NotificationScheduler.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Foundation
import OSLog
import UserNotifications

/// Turns `NotificationPlanner`'s plan into pending iOS notifications.
/// Safe to call as often as needed: stable identifiers mean each run
/// replaces the last one rather than adding duplicates.
final class NotificationScheduler {

    static let shared = NotificationScheduler()

    private static let logger = Logger(subsystem: "PeriodT", category: "Notifications")

    /// Key in `userInfo` holding the `AppNavigationViewModel.Tab` raw value to open on tap.
    static let tabKey = "tab"

    var planner = NotificationPlanner()

    private init() {}

    func reschedule(reviews: [PollAnswers], programs: [ExerciseProgram]) async {
        guard await NotificationManager.shared.isAuthorized() else { return }
        let center = UNUserNotificationCenter.current()
        let planned = planner.plan(reviews: reviews, programs: programs)

        // Drop anything of ours that's no longer in the plan (e.g. a check-in
        // the user has now done, or phases that moved after logging a period).
        let wanted = Set(planned.map(\.identifier))
        let stale = await center.pendingNotificationRequests()
            .map(\.identifier)
            .filter { $0.hasPrefix(PlannedNotification.identifierPrefix) && !wanted.contains($0) }
        center.removePendingNotificationRequests(withIdentifiers: stale)

        for notification in planned {
            do {
                try await center.add(Self.request(for: notification))
            } catch {
                Self.logger.error("Failed to schedule \(notification.identifier): \(error.localizedDescription)")
            }
        }
        Self.logger.info("Scheduled \(planned.count) notifications, removed \(stale.count)")
        Self.logger.debug("Pending: \(planned.map(\.identifier).joined(separator: ", "))")
    }

    private static func request(for notification: PlannedNotification) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.userInfo = [tabKey: notification.tab.rawValue]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                         from: notification.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: notification.identifier, content: content, trigger: trigger)
    }
}

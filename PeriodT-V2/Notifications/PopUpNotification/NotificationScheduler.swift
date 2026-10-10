//
//  NotificationScheduler.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//
//  Takes the plan from NotificationPlanner and turns it into real pending iOS
//  notifications, clearing out any of ours that aren't needed anymore.
//

import Foundation
import OSLog
import UserNotifications

/// Fine to call as often as you like. The identifiers are stable, so each run
/// replaces the last one rather than adding duplicates.
final class NotificationScheduler {

    static let shared = NotificationScheduler()

    private static let logger = Logger(subsystem: "PeriodT", category: "Notifications")

    /// The `userInfo` key holding which tab to open on tap.
    static let tabKey = "tab"

    var planner = NotificationPlanner()

    private init() {}

    func reschedule(reviews: [PollAnswers], programs: [ExerciseProgram]) async {
        guard await NotificationManager.shared.isAuthorized() else { return }
        let center = UNUserNotificationCenter.current()
        let planned = planner.plan(reviews: reviews, programs: programs)

        // Clear out anything of ours that's no longer in the plan, like a check-in
        // they've now done or phases that shifted after logging a period.
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

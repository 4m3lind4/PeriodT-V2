//
//  NotificationPlanner.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import Foundation

/// One pop-up we want iOS to show. Plain data, so the plan can be unit tested
/// without touching `UNUserNotificationCenter`.
struct PlannedNotification: Equatable {
    enum Kind: String, CaseIterable {
        case phaseChange = "phase"
        case periodDueSoon = "periodDue"
        case periodOverdue = "periodOverdue"
        case dailyCheckIn = "checkIn"
        case workout = "workout"
    }

    let kind: Kind
    let fireDate: Date
    let title: String
    let body: String

    /// Every identifier we schedule starts with this, so we only ever clear our own.
    static let identifierPrefix = "periodt."

    /// One per kind per day, so rescheduling replaces a notification instead of duplicating it.
    var identifier: String {
        "\(Self.identifierPrefix)\(kind.rawValue).\(Self.dayFormatter.string(from: fireDate))"
    }

    /// The tab a tap on this notification opens.
    var tab: AppNavigationViewModel.Tab {
        switch self.kind {
        case .phaseChange, .periodDueSoon, .periodOverdue: .calendar
        case .dailyCheckIn: .home
        case .workout: .exercise
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

/// Works out every notification to schedule from the user's reviews and programs.
/// iOS keeps at most 64 pending notifications per app, so we plan a few weeks
/// ahead and rebuild the plan whenever the data changes.
struct NotificationPlanner {
    var cycleLength = 28
    /// How far ahead to plan phase, period and workout notifications.
    var horizonDays = 35
    /// How many evenings of check-in reminders to plan.
    var checkInDays = 14
    /// Stays under iOS's limit of 64, keeping the soonest.
    var maxPending = 60

    static let phaseHour = 9
    static let periodHour = 9
    static let workoutHour = 8
    static let checkInHour = 20
    /// "Period due soon" goes out this many days before the predicted start.
    static let dueSoonLeadDays = 2
    /// "Log your period" goes out this many days after the predicted start.
    static let overdueAfterDays = 3

    func plan(reviews: [PollAnswers], programs: [ExerciseProgram], now: Date = Date()) -> [PlannedNotification] {
        let today = now.startOfDay
        let all = phaseChanges(reviews: reviews, from: today)
            + periodReminders(reviews: reviews)
            + checkIns(reviews: reviews, from: today)
            + workouts(programs: programs, from: today)
        return Array(all
            .filter { $0.fireDate > now }
            .sorted { $0.fireDate < $1.fireDate }
            .prefix(maxPending))
    }

    // MARK: - Each kind

    /// A notification on the first day of each predicted phase.
    private func phaseChanges(reviews: [PollAnswers], from today: Date) -> [PlannedNotification] {
        (0...horizonDays).compactMap { offset in
            let day = Self.day(offset, after: today)
            guard let phase = CyclePhase.phase(on: day, from: reviews, cycleLength: cycleLength),
                  phase != CyclePhase.phase(on: Self.day(-1, after: day), from: reviews, cycleLength: cycleLength)
            else { return nil }
            return PlannedNotification(kind: .phaseChange,
                                       fireDate: Self.time(Self.phaseHour, on: day),
                                       title: "PeriodT",
                                       body: phase.message)
        }
    }

    /// "Due soon" before the predicted period, and "log it" if it's a few days late.
    private func periodReminders(reviews: [PollAnswers]) -> [PlannedNotification] {
        let due = PeriodDueViewModel(cycleLength: cycleLength)
        guard let last = due.lastPeriodStart(in: reviews) else { return [] }
        let dueDay = Self.day(cycleLength, after: last.startOfDay)
        let soonDays = Self.dueSoonLeadDays
        return [
            PlannedNotification(kind: .periodDueSoon,
                                fireDate: Self.time(Self.periodHour, on: Self.day(-soonDays, after: dueDay)),
                                title: "Period due soon",
                                body: "Your period is due in \(soonDays) days 🩸 Pack what you need and plan training around it."),
            PlannedNotification(kind: .periodOverdue,
                                fireDate: Self.time(Self.periodHour, on: Self.day(Self.overdueAfterDays, after: dueDay)),
                                title: "Has your period started?",
                                body: "Your period was due a few days ago. Log it when it starts so your predictions stay accurate 💗")
        ]
    }

    /// An evening reminder on each day that doesn't have a check-in yet.
    private func checkIns(reviews: [PollAnswers], from today: Date) -> [PlannedNotification] {
        let checkedIn = Set(reviews.filter(\.hasCheckedIn).map { $0.date.startOfDay })
        return (0..<checkInDays).compactMap { offset in
            let day = Self.day(offset, after: today)
            guard !checkedIn.contains(day) else { return nil }
            return PlannedNotification(kind: .dailyCheckIn,
                                       fireDate: Self.time(Self.checkInHour, on: day),
                                       title: "Daily check-in",
                                       body: "How did today feel? Take a minute to log your check-in 📝")
        }
    }

    /// A morning reminder on each day with a program that isn't finished.
    private func workouts(programs: [ExerciseProgram], from today: Date) -> [PlannedNotification] {
        let end = Self.day(horizonDays + 1, after: today)
        let open = programs.filter { program in
            program.date >= today && program.date < end
                && !program.workouts.isEmpty
                && !program.workouts.allSatisfy(\.isCompleted)
        }
        let byDay = Dictionary(grouping: open) { $0.date.startOfDay }
        return byDay.map { day, programs in
            let body = programs.count == 1
                ? "Your \(programs[0].exerciseType.title) program is on today 💪"
                : "You've got \(programs.count) programs on today 💪"
            return PlannedNotification(kind: .workout,
                                       fireDate: Self.time(Self.workoutHour, on: day),
                                       title: "Training today",
                                       body: body)
        }
    }

    // MARK: - Dates

    private static func day(_ offset: Int, after day: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: day) ?? day
    }

    private static func time(_ hour: Int, on day: Date) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: day) ?? day
    }
}

extension NotificationPlanner {
    /// Only the parts of the data the plan depends on. Rescheduling when this
    /// changes (rather than on every edit) means typing a journal entry doesn't
    /// rebuild every notification on each keystroke.
    struct Inputs: Hashable {
        let periodDays: Set<Date>
        let checkedInDays: Set<Date>
        let openProgramDays: [Date]

        init(reviews: [PollAnswers], programs: [ExerciseProgram]) {
            periodDays = Set(reviews.filter { $0.answers[.onPeriod] == .yes }.map(\.date))
            checkedInDays = Set(reviews.filter(\.hasCheckedIn).map(\.date))
            openProgramDays = programs
                .filter { !$0.workouts.allSatisfy(\.isCompleted) }
                .map(\.date)
                .sorted()
        }
    }
}

extension PollAnswers {
    /// Whether the user has filled in anything for this day.
    var hasCheckedIn: Bool {
        !answers.isEmpty || emotion != nil || intensity != nil || !journal.isEmpty
    }
}

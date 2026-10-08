//
//  AppError.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
import Foundation

/// Every error the app can show the user, with the copy for the error card.
/// Kept as an enum so the wording lives in one place and can be unit tested.
enum AppError: Hashable {
    /// The user tapped a calendar day that hasn't happened yet.
    case futureDay(Date)
    /// Saving to Supabase failed for the given piece of content.
    case saveFailed(SaveTarget)
    /// The on-disk store couldn't be opened; the app is running in memory.
    case dataUnavailable

    /// What the user was trying to save, for the error copy.
    enum SaveTarget: String, Hashable {
        case pollAnswer = "your answer"
        case journal = "your journal"
        case workout = "your workout"
    }

    var title: String {
        switch self {
        case .futureDay(let day):
            day.formatted(.dateTime.weekday(.wide).day())
        case .saveFailed:
            "Couldn't save"
        case .dataUnavailable:
            "Your data couldn't be loaded"
        }
    }

    var message: String {
        switch self {
        case .futureDay:
            "This day is not available yet\n(its in the future silly)"
        case .saveFailed(let target):
            "Something went wrong saving \(target.rawValue). Please try again."
        case .dataUnavailable:
            "Anything you log this session won't be kept. Try restarting the app."
        }
    }

    /// Transient errors slide away on their own after a few seconds.
    /// A missing data store is permanent for the session, so it stays until dismissed.
    var autoDismisses: Bool {
        switch self {
        case .futureDay, .saveFailed: true
        case .dataUnavailable: false
        }
    }
}

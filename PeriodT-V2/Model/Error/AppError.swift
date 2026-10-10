//
//  AppError.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  Every error the user can actually see, along with the wording for the error card.
//

import Foundation

/// I kept these as an enum so all the wording lives in one place and the unit tests
/// can check it without having to render anything.
enum AppError: Hashable {
    /// The user tapped a calendar day that hasn't happened yet.
    case futureDay(Date)
    /// Saving to Supabase failed for the given piece of content.
    case saveFailed(SaveTarget)
    /// Data couldn't be loaded, so nothing logged this session will be kept.
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

    /// Quick errors slide away by themselves after a few seconds. Losing the data
    /// store lasts the whole session, so that one stays up until it's dismissed.
    var autoDismisses: Bool {
        switch self {
        case .futureDay, .saveFailed: true
        case .dataUnavailable: false
        }
    }
}

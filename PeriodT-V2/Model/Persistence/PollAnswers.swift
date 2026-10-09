//
//  PollAnswers.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation
import SwiftData
import OSLog

/// The user's yes/no poll answers for one calendar day. One record per day.
@Model
final class PollAnswers {
    private static let logger = Logger(subsystem: "PeriodT", category: "PollAnswers")
    @Attribute(.unique) var date: Date

    /// Stored as raw strings — SwiftData can't persist enum-keyed dictionaries.
    private var rawAnswers: [String: String] = [:]

    /// Free-text journal entry for the day.
    var journal: String = ""

    /// `Emotion.rawValue`; stored as a string so SwiftData can persist it.
    private var rawEmotion: String?

    /// 0 (very unpleasant) ... 4 (very pleasant). Nil until the user moves the slider.
    var intensity: Int?

    /// Typed view of `rawEmotion`; an unknown stored value reads as nil.
    var emotion: Emotion? {
        get { rawEmotion.flatMap(Emotion.init(rawValue:)) }
        set { rawEmotion = newValue?.rawValue }
    }

    /// Typed view of `rawAnswers`; unknown keys/values are skipped.
    var answers: [PollQuestionKind: ReviewAnswer] {
        var result: [PollQuestionKind: ReviewAnswer] = [:]
        for (key, value) in rawAnswers {
            if let kind = PollQuestionKind(rawValue: key),
               let answer = ReviewAnswer(rawValue: value) {
                result[kind] = answer
            }
        }
        return result
    }

    init(date: Date) {
        self.date = date.startOfDay
    }

    func answer(for question: PollQuestion) -> ReviewAnswer? {
        rawAnswers[question.kind.rawValue].flatMap(ReviewAnswer.init(rawValue:))
    }

    func setAnswer(_ answer: ReviewAnswer, for question: PollQuestion) {
        rawAnswers[question.kind.rawValue] = answer.rawValue
    }

    /// Returns the existing record for `day`, or inserts a fresh one.
    /// A failed fetch is logged and treated as "no record yet" — because
    /// `date` is unique, inserting a duplicate upserts rather than doubling up.
    static func fetchOrCreate(for day: Date, in context: ModelContext) -> PollAnswers {
        let start = day.startOfDay
        let descriptor = FetchDescriptor<PollAnswers>(
            predicate: #Predicate { $0.date == start }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
        } catch {
            logger.error("Failed to fetch PollAnswers for \(start): \(error.localizedDescription)")
        }
        let new = PollAnswers(date: start)
        context.insert(new)
        return new
    }

    /// Persists any pending changes. Returns false (and logs) if the save fails.
    @discardableResult
    static func save(_ context: ModelContext) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            logger.error("Failed to save poll answers: \(error.localizedDescription)")
            return false
        }
    }
}

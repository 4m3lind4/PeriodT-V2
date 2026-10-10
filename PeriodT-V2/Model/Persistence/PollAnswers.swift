//
//  PollAnswers.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation

/// The user's poll answers, mood and journal for one calendar day.
/// One row per user per day in Supabase's `daily_reviews` table.
struct PollAnswers: Codable, Equatable {
    /// The calendar day, normalised to `startOfDay`.
    let date: Date

    /// Keyed by `PollQuestionKind.rawValue`; stored as a jsonb object.
    private var rawAnswers: [String: String] = [:]

    /// Free-text journal entry for the day.
    var journal: String = ""

    /// `Emotion.rawValue`; unknown values read as nil.
    private var rawEmotion: String?

    /// 0 (very unpleasant) ... 4 (very pleasant). Nil until the user moves the slider.
    var intensity: Int?

    var emotion: Emotion? {
        get { rawEmotion.flatMap(Emotion.init(rawValue:)) }
        set { rawEmotion = newValue?.rawValue }
    }

    /// Workout journals from the completed-program screen, one per program,
    /// separate from the emotional `journal`. Kept inside the `answers` jsonb as
    /// "workout_journal:<program id>" so no new column is needed; `answers` below skips these keys.
    var workoutJournals: [UUID: String] {
        var result: [UUID: String] = [:]
        for (key, value) in rawAnswers where key.hasPrefix(Self.workoutJournalPrefix) {
            if let id = UUID(uuidString: String(key.dropFirst(Self.workoutJournalPrefix.count))) {
                result[id] = value
            }
        }
        return result
    }

    func workoutJournal(for programID: UUID) -> String {
        rawAnswers[Self.workoutJournalPrefix + programID.uuidString] ?? ""
    }

    mutating func setWorkoutJournal(_ text: String, for programID: UUID) {
        rawAnswers[Self.workoutJournalPrefix + programID.uuidString] = text
    }

    private static let workoutJournalPrefix = "workout_journal:"

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

    mutating func setAnswer(_ answer: ReviewAnswer, for question: PollQuestion) {
        setAnswer(answer, for: question.kind)
    }

    mutating func setAnswer(_ answer: ReviewAnswer, for kind: PollQuestionKind) {
        rawAnswers[kind.rawValue] = answer.rawValue
    }

    // MARK: - Supabase row

    /// `user_id` is left out: the database fills it from the signed-in user.
    enum CodingKeys: String, CodingKey {
        case date = "day"
        case rawAnswers = "answers"
        case rawEmotion = "emotion"
        case journal, intensity
    }

    /// `day` is a Postgres `date`, sent as "yyyy-MM-dd" in the local calendar.
    /// A full timestamp would be converted to UTC and could land on the wrong day.
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dayString = try container.decode(String.self, forKey: .date)
        guard let day = Self.dayFormatter.date(from: dayString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container,
                                                   debugDescription: "Bad day: \(dayString)")
        }
        date = day.startOfDay
        rawAnswers = try container.decodeIfPresent([String: String].self, forKey: .rawAnswers) ?? [:]
        journal = try container.decodeIfPresent(String.self, forKey: .journal) ?? ""
        rawEmotion = try container.decodeIfPresent(String.self, forKey: .rawEmotion)
        intensity = try container.decodeIfPresent(Int.self, forKey: .intensity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.dayFormatter.string(from: date), forKey: .date)
        try container.encode(rawAnswers, forKey: .rawAnswers)
        try container.encode(journal, forKey: .journal)
        // Explicit nulls so clearing a value on an existing row sticks.
        try container.encode(rawEmotion, forKey: .rawEmotion)
        try container.encode(intensity, forKey: .intensity)
    }
}

//
//  PollAnswersTests.swift
//  PeriodT-V2Tests
//
//  Tests the daily review model, including the Supabase encoding and decoding
//  (the date handling here is easy to get wrong across time zones).
//

import Foundation
import SwiftUI
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("PollAnswers")
struct PollAnswersTests {

    // MARK: - Local editing

    @Test func initNormalisesDateToStartOfDay() {
        let afternoon = TestDates.date(2026, 10, 7, hour: 15)
        let answers = PollAnswers(date: afternoon)
        #expect(answers.date == afternoon.startOfDay)
    }

    @Test func newReviewIsEmpty() {
        let answers = PollAnswers(date: .now)
        #expect(answers.answers.isEmpty)
        #expect(answers.journal.isEmpty)
        #expect(answers.emotion == nil)
        #expect(answers.intensity == nil)
        #expect(answers.workoutJournals.isEmpty)
    }

    @Test func setAnswerByKindIsReadableByQuestion() {
        var answers = PollAnswers(date: .now)
        answers.setAnswer(.yes, for: .onPeriod)
        let question = PollQuestion(kind: .onPeriod, text: "Were you on your period?", color: .pink)
        #expect(answers.answer(for: question) == .yes)
        #expect(answers.answers[.onPeriod] == .yes)
        #expect(answers.answers[.trained] == nil)
    }

    @Test func setAnswerOverwritesPreviousAnswer() {
        var answers = PollAnswers(date: .now)
        answers.setAnswer(.yes, for: .trained)
        answers.setAnswer(.no, for: .trained)
        #expect(answers.answers[.trained] == .no)
        #expect(answers.answers.count == 1)
    }

    @Test(arguments: Emotion.allCases)
    func emotionRoundTrips(_ emotion: Emotion) {
        var answers = PollAnswers(date: .now)
        answers.emotion = emotion
        #expect(answers.emotion == emotion)
        answers.emotion = nil
        #expect(answers.emotion == nil)
    }

    // MARK: - Workout journals

    @Test func workoutJournalsAreStoredPerProgram() {
        var answers = PollAnswers(date: .now)
        let first = UUID(), second = UUID()
        answers.setWorkoutJournal("Legs felt heavy", for: first)
        answers.setWorkoutJournal("Great pace", for: second)

        #expect(answers.workoutJournal(for: first) == "Legs felt heavy")
        #expect(answers.workoutJournal(for: second) == "Great pace")
        #expect(answers.workoutJournal(for: UUID()) == "")
        #expect(answers.workoutJournals == [first: "Legs felt heavy", second: "Great pace"])
    }

    @Test func workoutJournalsDoNotLeakIntoPollAnswers() {
        var answers = PollAnswers(date: .now)
        answers.setWorkoutJournal("yes", for: UUID())
        answers.setAnswer(.no, for: .trained)
        #expect(answers.answers == [.trained: .no])
    }

    @Test func workoutJournalsAreSeparateFromEmotionalJournal() {
        var answers = PollAnswers(date: .now)
        let programID = UUID()
        answers.journal = "Feeling calm"
        answers.setWorkoutJournal("Hard session", for: programID)
        #expect(answers.journal == "Feeling calm")
        #expect(answers.workoutJournal(for: programID) == "Hard session")
    }

    // MARK: - Supabase decoding

    private func decode(_ json: String) throws -> PollAnswers {
        try JSONDecoder().decode(PollAnswers.self, from: Data(json.utf8))
    }

    @Test func decodesFullRow() throws {
        let programID = UUID()
        let answers = try decode("""
        {"day": "2026-10-07",
         "answers": {"trained": "yes", "onPeriod": "no", "workout_journal:\(programID.uuidString)": "Strong"},
         "journal": "Good day", "emotion": "happy", "intensity": 3}
        """)

        #expect(answers.date == TestDates.date(2026, 10, 7).startOfDay)
        #expect(answers.answers == [.trained: .yes, .onPeriod: .no])
        #expect(answers.journal == "Good day")
        #expect(answers.emotion == .happy)
        #expect(answers.intensity == 3)
        #expect(answers.workoutJournal(for: programID) == "Strong")
    }

    @Test func decodesMinimalRowWithDefaults() throws {
        let answers = try decode(#"{"day": "2026-01-31"}"#)
        #expect(answers.date == TestDates.date(2026, 1, 31).startOfDay)
        #expect(answers.answers.isEmpty)
        #expect(answers.journal == "")
        #expect(answers.emotion == nil)
        #expect(answers.intensity == nil)
    }

    @Test func decodesNullsAsNil() throws {
        let answers = try decode(#"{"day": "2026-01-31", "emotion": null, "intensity": null, "journal": null}"#)
        #expect(answers.emotion == nil)
        #expect(answers.intensity == nil)
        #expect(answers.journal == "")
    }

    @Test func unknownValuesAreSkipped() throws {
        let answers = try decode("""
        {"day": "2026-10-07", "emotion": "ecstatic",
         "answers": {"trained": "maybe", "notAQuestion": "yes", "onPeriod": "yes"}}
        """)
        #expect(answers.emotion == nil)
        #expect(answers.answers == [.onPeriod: .yes])
    }

    @Test(arguments: ["07/10/2026", "2026-13-01", "", "2026-10-07T10:00:00Z"])
    func badDayFailsToDecode(_ day: String) {
        #expect(throws: DecodingError.self) {
            try decode(#"{"day": "\#(day)"}"#)
        }
    }

    // MARK: - Supabase encoding

    private func encodeToDictionary(_ answers: PollAnswers) throws -> [String: Any] {
        let data = try JSONEncoder().encode(answers)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    @Test func encodesDayAsLocalCalendarDate() throws {
        // Late evening is where a UTC timestamp would roll over to the next day.
        let answers = PollAnswers(date: TestDates.date(2026, 10, 7, hour: 23))
        let json = try encodeToDictionary(answers)
        #expect(json["day"] as? String == "2026-10-07")
    }

    @Test func encodesClearedValuesAsExplicitNulls() throws {
        let json = try encodeToDictionary(PollAnswers(date: .now))
        #expect(json["emotion"] is NSNull)
        #expect(json["intensity"] is NSNull)
        #expect(json["journal"] as? String == "")
        #expect((json["answers"] as? [String: String])?.isEmpty == true)
    }

    @Test func doesNotSendUserID() throws {
        let json = try encodeToDictionary(PollAnswers(date: .now))
        #expect(json["user_id"] == nil)
        #expect(Set(json.keys) == ["day", "answers", "journal", "emotion", "intensity"])
    }

    @Test func encodeDecodeRoundTrip() throws {
        var original = Fixtures.review(on: TestDates.date(2026, 3, 29), onPeriod: .yes, trained: .no,
                                       emotion: .stressed, intensity: 0, journal: "Cramps 😣\nskipped gym")
        original.setWorkoutJournal("Light stretch", for: UUID())

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PollAnswers.self, from: data)
        #expect(decoded == original)
    }
}

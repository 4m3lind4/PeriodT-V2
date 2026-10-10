//
//  EnumAndConstantTests.swift
//  PeriodT-V2Tests
//
//  Small value types whose raw values are persisted or shown to the user.
//

import Foundation
import SwiftUI
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("Enums & constants")
struct EnumAndConstantTests {

    @Test func emotionRawValuesArePersistedNames() {
        #expect(Emotion.allCases.map(\.rawValue) == ["happy", "calm", "neutral", "sad", "stressed"])
    }

    @Test func reviewAnswerRawValues() {
        #expect(ReviewAnswer(rawValue: "yes") == .yes)
        #expect(ReviewAnswer(rawValue: "no") == .no)
        #expect(ReviewAnswer(rawValue: "Yes") == nil)
    }

    @Test func pollQuestionKindRawValuesAreStable() {
        #expect(PollQuestionKind.allCases.map(\.rawValue) ==
                ["trained", "onPeriod", "informCoachPeriod", "informCoachWorkout"])
    }

    @Test(arguments: PollQuestionKind.allCases)
    func everyQuestionHasASummaryTitle(_ kind: PollQuestionKind) {
        #expect(kind.summaryTitle.hasSuffix("?"))
    }

    @Test func dailyPollAsksEveryQuestionOnceInOrder() {
        let model = DayPoleModel()
        #expect(model.questions.map(\.kind) == PollQuestionKind.allCases)
        #expect(model.questions.allSatisfy { !$0.text.isEmpty })
    }

    @Test func journalTypeTitles() {
        #expect(JournalType.emotional.title == "Emotional")
        #expect(JournalType.workout.title == "Workout")
        #expect(JournalType.workout.id == "workout")
    }

    @Test func journalTypeColours() {
        #expect(JournalType.workout.color == CoreColor.primary)
        #expect(JournalType.emotional.color == CoreColor.accent)
    }

    @Test func programStatusColours() {
        #expect(ProgramStatus.completed.color == CoreColor.completed)
        #expect(ProgramStatus.missed.color == CoreColor.missed)
        #expect(ProgramStatus.current.color == CoreColor.current)
        #expect(ProgramStatus.incoming.color == CoreColor.incoming)
    }

    @Test func intensityDefaultIsMiddleStep() {
        #expect(IntensitySliderView.defaultIntensity == StepSliderView.steps / 2)
    }
}

@MainActor
@Suite("JournalEntry identity")
struct JournalEntryTests {
    private let day = TestDates.date(2026, 10, 7).startOfDay

    @Test func emotionalAndWorkoutEntriesOnSameDayHaveDistinctIDs() {
        let emotional = JournalEntry(date: day, type: .emotional, text: "a")
        let workout = JournalEntry(date: day, type: .workout, text: "b", programID: UUID())
        #expect(emotional.id != workout.id)
    }

    @Test func workoutEntriesForDifferentProgramsHaveDistinctIDs() {
        let first = JournalEntry(date: day, type: .workout, text: "a", programID: UUID())
        let second = JournalEntry(date: day, type: .workout, text: "a", programID: UUID())
        #expect(first.id != second.id)
    }

    @Test func idIsStableForTheSameEntry() {
        let programID = UUID()
        let first = JournalEntry(date: day, type: .workout, text: "old", programID: programID)
        let edited = JournalEntry(date: day, type: .workout, text: "new", programID: programID)
        #expect(first.id == edited.id)
    }
}

//
//  ExerciseProgramTests.swift
//  PeriodT-V2Tests
//
//  Tests programs and workouts: decoding from Supabase, set counts and status.
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("ExerciseProgram & Workout")
struct ExerciseProgramTests {

    // MARK: - Workout

    @Test(arguments: [(Int?.none, 1), (0, 1), (1, 1), (3, 3), (12, 12)])
    func setCountIsAtLeastOne(sets: Int?, expected: Int) {
        #expect(Workout(name: "Plank", sets: sets).setCount == expected)
    }

    @Test func workoutDecodesCompletionRowAsCompleted() throws {
        let json = """
        {"id": "\(UUID().uuidString)", "name": "Plank", "sets": 3, "reps": 10, "rest_seconds": 30,
         "workout_completions": [{"completed_at": "2026-10-07T09:00:00Z"}]}
        """
        let workout = try isoDecoder.decode(Workout.self, from: Data(json.utf8))
        #expect(workout.isCompleted)
        #expect(workout.sets == 3)
        #expect(workout.reps == 10)
        #expect(workout.restSeconds == 30)
    }

    @Test(arguments: [#""workout_completions": [], "#, ""])
    func workoutWithoutCompletionsIsNotCompleted(completions: String) throws {
        let json = #"{\#(completions)"id": "\#(UUID().uuidString)", "name": "Walking"}"#
        let workout = try isoDecoder.decode(Workout.self, from: Data(json.utf8))
        #expect(!workout.isCompleted)
        #expect(workout.sets == nil)
        #expect(workout.reps == nil)
        #expect(workout.restSeconds == nil)
    }

    @Test func workoutEncodingOmitsCompletionState() throws {
        let workout = Workout(name: "Plank", sets: 3, reps: 10, restSeconds: 20, isCompleted: true)
        let data = try JSONEncoder().encode(workout)
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(Set(json.keys) == ["id", "name", "sets", "reps", "rest_seconds"])
    }

    @Test func workoutEncodingSkipsNilFields() throws {
        let data = try JSONEncoder().encode(Workout(name: "Walking"))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(Set(json.keys) == ["id", "name"])
    }

    // MARK: - ExerciseProgram

    private var isoDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    @Test func programDecodesSnakeCaseRowWithNestedWorkouts() throws {
        let programID = UUID()
        let json = """
        {"id": "\(programID.uuidString)", "date": "2026-10-10T09:00:00Z", "day": 3,
         "exercise_duration": 40, "number_of_exercises": 2, "exercise_type": "conditioningTraining",
         "workouts": [
            {"id": "\(UUID().uuidString)", "name": "Hip Thrust", "sets": 3,
             "workout_completions": [{"completed_at": "2026-10-10T10:00:00Z"}]},
            {"id": "\(UUID().uuidString)", "name": "Plank", "workout_completions": []}
         ]}
        """
        let program = try isoDecoder.decode(ExerciseProgram.self, from: Data(json.utf8))
        #expect(program.id == programID)
        #expect(program.day == 3)
        #expect(program.exerciseDuration == 40)
        #expect(program.numberOfExercises == 2)
        #expect(program.exerciseType == .conditioningTraining)
        #expect(program.workouts.map(\.name) == ["Hip Thrust", "Plank"])
        #expect(program.workouts.map(\.isCompleted) == [true, false])
    }

    @Test func programWithUnknownTypeFailsToDecode() {
        let json = """
        {"id": "\(UUID().uuidString)", "date": "2026-10-10T09:00:00Z", "day": 1,
         "exercise_duration": 40, "number_of_exercises": 0, "exercise_type": "yoga", "workouts": []}
        """
        #expect(throws: DecodingError.self) {
            try isoDecoder.decode(ExerciseProgram.self, from: Data(json.utf8))
        }
    }

    @Test func formattedDateIsUppercasedShortForm() {
        // 14 September 2026 is a Monday.
        let program = Fixtures.program(on: TestDates.date(2026, 9, 14))
        #expect(program.formattedDate == "MON 14 SEP")
    }

    @Test func dateNumberIsDayOfMonth() {
        let program = Fixtures.program(on: .now)
        #expect(program.dateNumber(date: TestDates.date(2026, 9, 14)) == 14)
        #expect(program.dateNumber(date: TestDates.date(2026, 2, 1)) == 1)
    }

    // MARK: - ProgramStatus

    @Test func programTodayIsCurrentAtAnyHour() {
        let today = Date().startOfDay
        #expect(Fixtures.program(on: today).status == .current)
        #expect(Fixtures.program(on: today.addingTimeInterval(23 * 3600 + 59 * 60)).status == .current)
    }

    @Test func pastProgramWithAllWorkoutsTickedIsCompleted() {
        let done = Workout(name: "Plank", sets: 3, isCompleted: true)
        #expect(Fixtures.program(on: TestDates.daysFromToday(-1), workouts: [done, done]).status == .completed)
    }

    @Test func pastProgramWithUntickedWorkoutsIsMissed() {
        let done = Workout(name: "Plank", sets: 3, isCompleted: true)
        let notDone = Workout(name: "Squat", sets: 3)
        #expect(Fixtures.program(on: TestDates.daysFromToday(-1)).status == .missed)
        #expect(Fixtures.program(on: TestDates.daysFromToday(-1), workouts: [done, notDone]).status == .missed)
        #expect(Fixtures.program(on: TestDates.daysFromToday(-1), workouts: []).status == .missed)
    }

    @Test func programTomorrowIsIncoming() {
        #expect(Fixtures.program(on: TestDates.daysFromToday(1)).status == .incoming)
    }

    // MARK: - ExerciseType

    @Test func exerciseTypeTitles() {
        #expect(ExerciseType.physio.title == "Physio")
        #expect(ExerciseType.conditioningTraining.title == "Conditioning")
    }

    @Test func exerciseTypeRawValuesMatchDatabase() {
        #expect(ExerciseType.allCases.map(\.rawValue) == ["physio", "conditioningTraining"])
    }
}

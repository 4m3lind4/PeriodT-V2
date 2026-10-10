//
//  MockPeriodTRepositoryTests.swift
//  PeriodT-V2Tests
//
//  The mock backs previews and the UI tests, so its behaviour needs to match the real repository's contract.
//

import Foundation
import Testing
@testable import PeriodT_V2

@MainActor
@Suite("MockPeriodTRepository")
struct MockPeriodTRepositoryTests {

    @Test func fetchReturnsProgramsSoonestFirst() async throws {
        let later = Fixtures.program(on: TestDates.daysFromToday(3), day: 2)
        let sooner = Fixtures.program(on: TestDates.daysFromToday(-3), day: 1)
        let repository = MockPeriodTRepository(programs: [later, sooner], pollAnswers: [])

        let programs = try await repository.fetchWorkouts()
        #expect(programs.map(\.day) == [1, 2])
    }

    @Test func addedProgramIsFetched() async throws {
        let repository = MockPeriodTRepository(programs: [], pollAnswers: [])
        let program = Fixtures.program(on: .now, day: 9)

        try await repository.addProgram(program)

        #expect(try await repository.fetchWorkouts().map(\.id) == [program.id])
    }

    @Test func addingTheSameProgramTwiceKeepsOneCopy() async throws {
        let repository = MockPeriodTRepository(programs: [])
        let program = Fixtures.program(on: TestDates.daysFromToday(1))
        try await repository.addProgram(program)
        try await repository.addProgram(program)
        #expect(try await repository.fetchWorkouts().map(\.id) == [program.id])
    }

    @Test func saveCompletedWorkoutsMakesSetTheFullTickedList() async throws {
        let workouts = [Workout(name: "A", isCompleted: true), Workout(name: "B"), Workout(name: "C")]
        let program = Fixtures.program(on: .now, workouts: workouts)
        let repository = MockPeriodTRepository(programs: [program], pollAnswers: [])

        // Tick B, untick A.
        try await repository.saveCompletedWorkouts([workouts[1].id], in: program)

        let saved = try #require(try await repository.fetchWorkouts().first)
        #expect(saved.workouts.map(\.isCompleted) == [false, true, false])
        #expect(saved.id == program.id)
    }

    @Test func saveCompletedWorkoutsForUnknownProgramIsIgnored() async throws {
        let repository = MockPeriodTRepository(programs: [], pollAnswers: [])
        try await repository.saveCompletedWorkouts([], in: Fixtures.program(on: .now))
        #expect(try await repository.fetchWorkouts().isEmpty)
    }

    @Test func savingSameDayReplacesReview() async throws {
        let repository = MockPeriodTRepository(programs: [], pollAnswers: [])
        let day = TestDates.daysFromToday(-1)

        try await repository.savePollAnswers(Fixtures.review(on: day, journal: "first"))
        try await repository.savePollAnswers(Fixtures.review(on: day.addingTimeInterval(3600), journal: "second"))

        let reviews = try await repository.fetchPollAnswers()
        #expect(reviews.map(\.journal) == ["second"])
    }

    @Test func failingMockThrowsFromEveryCall() async {
        let repository = MockPeriodTRepository(shouldFail: true)
        let program = Fixtures.program(on: .now)
        await #expect(throws: URLError.self) { try await repository.fetchWorkouts() }
        await #expect(throws: URLError.self) { try await repository.fetchPollAnswers() }
        await #expect(throws: URLError.self) { try await repository.addProgram(program) }
        await #expect(throws: URLError.self) { try await repository.saveCompletedWorkouts([], in: program) }
        await #expect(throws: URLError.self) { try await repository.savePollAnswers(PollAnswers(date: .now)) }
    }

    // MARK: - Sample data the UI tests rely on

    @Test func sampleProgramsHaveOneProgramToday() {
        let today = MockPeriodTRepository.samplePrograms.filter { $0.status == .current }
        #expect(today.count == 1)
        #expect(today.first?.workouts.first?.name == "Hip Thrust")
    }

    @Test func sampleProgramsSplitAcrossSections() {
        let statuses = MockPeriodTRepository.samplePrograms.map(\.status)
        #expect(statuses.filter { $0 == .completed }.count == 3)
        #expect(statuses.filter { $0 == .incoming }.count == 3)
    }

    @Test func sampleProgramCountsMatchWorkouts() {
        for program in MockPeriodTRepository.samplePrograms {
            #expect(program.numberOfExercises == program.workouts.count)
        }
    }

    @Test func samplePeriodStartedFiveDaysAgoSoDueIn23Days() {
        let reviews = MockPeriodTRepository.samplePollAnswers
        #expect(PeriodDueViewModel().dueText(for: reviews) == "23 Days")
    }

    @Test(arguments: Set(MockPeriodTRepository.samplePrograms.flatMap(\.workouts).map(\.name)).sorted())
    func sampleWorkoutHasThumbnail(_ name: String) {
        withKnownIssue("ExerciseImages.csv has a \"Bird Dog\" row with no URL") {
            #expect(ExerciseImageCatalog.imageURL(for: name) != nil)
        } when: {
            name == "Bird Dog"
        }
    }
}

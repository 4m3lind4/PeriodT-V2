//
//  PeriodTExercises.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//


//
//  PeriodTExercises.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//

import SwiftUI

/// Exercise tab: lists programs split by type, with one card expandable at a time.
struct PeriodTExercises: View {
    let repository: IPeriodTRepository
    @State var exerciseData: [ExerciseProgram] = []
    @State private var errorMessage: String?
    
    // Only one card is open at once; shared across both lists.
    @State private var expandedProgramID: ExerciseProgram.ID?

    var exerciseProgram: [ExerciseProgram] {
        exerciseData.filter { $0.exerciseType == .conditioningTraining }
    }
    var physioProgram: [ExerciseProgram] {
        exerciseData.filter { $0.exerciseType == .physio }
    }

    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 12){
            ScreenHeader(title: "Today's Program")

            programSection(title: "Exercise Programs", programs: exerciseProgram)
            programSection(title: "Physio Programs", programs: physioProgram)
        }
        .padding(10)
        }
        .task { await load() }
        .refreshable { await load() }
    }

    /// Section heading followed by one expandable card per program.
    @ViewBuilder
    private func programSection(title: String, programs: [ExerciseProgram]) -> some View {
        Text(title)
            .font(.title2)
            .foregroundColor(CoreColor.primary)
        ForEach(programs) { program in
            ExpandableProgramCard(program: program, expandedProgramID: $expandedProgramID)
        }
    }
    private func load() async {
        do {
            exerciseData = try await repository.fetchWorkouts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    PeriodTExercises(repository: MockPeriodTRepository())
}

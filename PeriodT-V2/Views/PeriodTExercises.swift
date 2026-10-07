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

/// Exercise tab: lists programs grouped into today, incoming and completed,
/// with one card expandable at a time. Physio programs are marked on the card itself.
struct PeriodTExercises: View {
    let repository: IPeriodTRepository
    @State var exerciseData: [ExerciseProgram] = []
    @State private var errorMessage: String?

    // Only one card is open at once; shared across all sections.
    @State private var expandedProgramID: ExerciseProgram.ID?
    @State private var showAllIncoming = false
    @State private var showAllCompleted = false

    /// Cards shown per section before "View More".
    private let previewCount = 2

    var todaysPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .current }
    }
    /// Soonest first (data arrives sorted by date ascending).
    var incomingPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .incoming }
    }
    /// Most recent first.
    var completedPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .completed }.reversed()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Today's Program")

                if todaysPrograms.isEmpty {
                    Text("Rest day - nothing scheduled")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(CoreColor.primary.opacity(0.7))
                } else {
                    cards(todaysPrograms)
                }

                programSection(title: "Incoming", programs: incomingPrograms, showAll: $showAllIncoming)
                programSection(title: "Completed", programs: completedPrograms, showAll: $showAllCompleted)
            }
            .padding(16)
        }
        // Keeps the last card clear of the floating tab bar.
        .contentMargins(.bottom, 100, for: .scrollContent)
        .task { await load() }
        .refreshable { await load() }
    }

    /// Section heading, the first few cards, and a View More / View Less toggle.
    @ViewBuilder
    private func programSection(title: String,
                                programs: [ExerciseProgram],
                                showAll: Binding<Bool>) -> some View {
        if !programs.isEmpty {
            Text(title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(CoreColor.primary)
                .padding(.top, 12)

            cards(showAll.wrappedValue ? programs : Array(programs.prefix(previewCount)))

            if programs.count > previewCount {
                Button {
                    withAnimation(.snappy) { showAll.wrappedValue.toggle() }
                } label: {
                    Text(showAll.wrappedValue ? "View Less" : "View More")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(CoreColor.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func cards(_ programs: [ExerciseProgram]) -> some View {
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

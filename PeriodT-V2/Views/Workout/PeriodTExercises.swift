//
//  PeriodTExercises.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//
//  The Exercise tab. Programs are grouped into today, incoming, missed and
//  completed, and this view owns the NavigationStack for the whole workout flow
//  (program, then sets, then the completed screen).
//

import SwiftUI
import Lottie

struct PeriodTExercises: View {
    let repository: IPeriodTRepository
    @EnvironmentObject private var navigation: AppNavigationViewModel
    @State var exerciseData: [ExerciseProgram] = []
    @State private var errorMessage: String?
    /// False until the first fetch finishes, which is when the loading animation goes away.
    @State private var hasLoaded = false

    // Only one card can be open at once, across every section.
    @State private var expandedProgramID: ExerciseProgram.ID?
    @State private var showAllIncoming = false
    @State private var showAllMissed = false
    @State private var showAllCompleted = false

    /// How many cards each section shows before "View More".
    private let previewCount = 2

    var todaysPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .current }
    }
    /// Soonest first, since the data already comes back sorted by date.
    var incomingPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .incoming }
    }
    /// Past programs with workouts left unticked, most recent first.
    var missedPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .missed }.reversed()
    }
    /// Past programs with every workout ticked, most recent first.
    var completedPrograms: [ExerciseProgram] {
        exerciseData.filter { $0.status == .completed }.reversed()
    }

    var body: some View {
        // Bound to the shared path so screens further in can push or pop by editing it.
        NavigationStack(path: $navigation.exercisePath) {
            programList
                // "Start" on a card opens that program.
                .navigationDestination(for: ExerciseProgram.self) { program in
                    ActiveInProgramView(program: program, repository: repository)
                }
                // ActiveInProgramView pushes this after a successful submit.
                .navigationDestination(for: ExerciseFlow.self) { step in
                    switch step {
                    case .completed(let program):
                        ProgramCompletedView(program: program)
                    }
                }
        }
    }

    private var programList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ScreenHeader(title: "Today's Program")

                // Without this a failed first load would just look like an empty schedule.
                if errorMessage != nil && exerciseData.isEmpty {
                    Text("Couldn't load your programs. Pull down to try again.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(CoreColor.primary.opacity(0.7))
                } else if todaysPrograms.isEmpty {
                    Text("Rest day - nothing scheduled")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(CoreColor.primary.opacity(0.7))
                } else {
                    cards(todaysPrograms)
                }

                programSection(title: "Incoming", programs: incomingPrograms, showAll: $showAllIncoming)
                programSection(title: "Missed", programs: missedPrograms, showAll: $showAllMissed)
                programSection(title: "Completed", programs: completedPrograms, showAll: $showAllCompleted)
            }
            .padding(16)
        }
        // Stops the last card hiding behind the tab bar.
        .contentMargins(.bottom, 100, for: .scrollContent)
        // Only for the very first fetch, so pull-to-refresh doesn't flash it up again.
        .overlay {
            if !hasLoaded {
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    LottieView(animationName: "Loading", loopMode: .loop)
                        .frame(width: 200, height: 200)
                }
                .transition(.opacity)
            }
        }
        .task { await load() }
        .refreshable { await load() }
        // Back on the list after a submit, so refetch to pick up the saved ticks.
        .onChange(of: navigation.exercisePath.isEmpty) { _, isEmpty in
            if isEmpty { Task { await load() } }
        }
    }

    /// A section heading, the first few cards and a View More / View Less button.
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
        withAnimation { hasLoaded = true }
    }
}

#Preview {
    PeriodTExercises(repository: MockPeriodTRepository())
        .errorCardHost()
        .environmentObject(AppNavigationViewModel())
}

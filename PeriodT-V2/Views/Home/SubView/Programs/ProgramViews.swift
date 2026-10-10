//
//  ProgramViews.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 12/9/2026.
//

import SwiftUI

/// "Today Programs" section: heading plus a horizontal scroll of program cards.
struct ProgramViews: View {
    let programs: [ExerciseProgram]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text("Today Programs")
                    .font(Font.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(CoreColor.primary)

                Text("Here are your assigned programs:")
                    .font(.title3)
                    .foregroundStyle(CoreColor.primary)
            }
            .padding(.horizontal, 22)

            if programs.isEmpty {
                NoProgramsCard()
                    .padding(.horizontal, 22)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(programs.prefix(5)) { program in
                            ProgramCard(program: program)
                        }
                    }
                    .padding(.horizontal, 22)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgramViews(programs: [
            ExerciseProgram(date: Date(), day: 1, exerciseDuration: 60, numberOfExercises: 6, exerciseType: .physio, workouts: []),
            ExerciseProgram(date: Date().addingTimeInterval(86_400), day: 2, exerciseDuration: 45, numberOfExercises: 5, exerciseType: .conditioningTraining, workouts: [])
        ])
        ProgramViews(programs: [])
    }
}

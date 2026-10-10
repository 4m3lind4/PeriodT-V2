//
//  ProgramCards.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI


/// Compact program card used in the Home horizontal carousel.
/// Colour band on top shows the program's status, matching the Exercise tab cards.
struct ProgramCard: View {
    let program: ExerciseProgram

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status band: completed / current / incoming.
            program.status.color
                .frame(height: 20)

            VStack(alignment: .leading, spacing: 8) {
                Text(program.formattedDate.uppercased())
                Text("Day \(program.day)")
                Text("\(program.numberOfExercises) Exercises - \(program.exerciseDuration) Mins")
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(CoreColor.primary)
            .padding(.horizontal, 30)
            .padding(.vertical, 14)
        }
        .frame(width: 260, alignment: .leading)
        .background(CoreColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Shown in place of the carousel when nothing is scheduled.
struct NoProgramsCard: View {
    var body: some View {
        Text("No Exercises due!\nEnjoy freedom🎉")
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(CoreColor.primary)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(CoreColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgramCard(
            program: ExerciseProgram(
                date: Date(), day: 1, exerciseDuration: 60, numberOfExercises: 6, exerciseType: .physio, workouts: []
            )
        )
        NoProgramsCard()
            .padding(.horizontal)
    }
}

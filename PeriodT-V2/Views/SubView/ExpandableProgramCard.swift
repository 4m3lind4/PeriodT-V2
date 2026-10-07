//
//  ExpandableProgramCard.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//


//
//  ExpandableProgramCard.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Program summary card that expands to reveal its workouts and a Start button.
/// Expansion is controlled by the parent so only one card is open at a time.
struct ExpandableProgramCard: View {
    let program: ExerciseProgram
    @Binding var expandedProgramID: ExerciseProgram.ID?

    private var isExpanded: Bool { expandedProgramID == program.id }

    var body: some View {
        VStack(spacing: 0) {
            header

            if isExpanded {
                workoutList
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(CoreColor.ringBackground.opacity(isExpanded ? 0.6 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.snappy(duration: 0.3), value: isExpanded)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(program.formattedDate)
                Text("Day \(program.day)")
                Text("\(program.numberOfExercises) Exercises - \(program.exerciseDuration) Mins")
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))

            Spacer()

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 22))
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(program.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            // Tapping an open card closes it; tapping another swaps to it.
            expandedProgramID = isExpanded ? nil : program.id
        }
    }

    private var workoutList: some View {
        VStack(spacing: 12) {
            ForEach(program.workouts) { workout in
                WorkoutRow(workout: workout)
            }
            // Pushes onto the NavigationStack owned by PeriodTExercises.
            NavigationLink(value: program) {
                PrimaryButtonLabel(title: "Start", style: .filled)
            }
            .padding(.top, 8)
        }
        .padding(12)
    }
}


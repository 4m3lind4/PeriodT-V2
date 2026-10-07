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
        .animation(.snappy(duration: 0.3), value: isExpanded)
    }

    private let stripeWidth: CGFloat = 18
    private let physioWidth: CGFloat = 6
    private var isPhysio: Bool { program.exerciseType == .physio }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(program.formattedDate.uppercased())
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
        .padding(.leading, stripeWidth + (isPhysio ? physioWidth : 0))
        .foregroundStyle(CoreColor.primary)
        // Stripe sits in the background so it always matches the text height.
        .background(alignment: .leading) { statusStripe }
        .background(CoreColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .onTapGesture {
            // Tapping an open card closes it; tapping another swaps to it.
            expandedProgramID = isExpanded ? nil : program.id
        }
    }

    /// Left edge: status colour, plus a yellow strip for physio programs.
    private var statusStripe: some View {
        HStack(spacing: 0) {
            program.status.color.frame(width: stripeWidth)
            if isPhysio {
                CoreColor.physioAccent.frame(width: physioWidth)
            }
        }
    }

    /// Inset pink panel of workouts, with the Start button underneath it.
    private var workoutList: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ForEach(program.workouts) { workout in
                    WorkoutRow(workout: workout)

                    if workout.id != program.workouts.last?.id {
                        Rectangle()
                            .fill(CoreColor.primary)
                            .frame(height: 1.5)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .padding(12)
            .background(CoreColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)

            // Pushes onto the NavigationStack owned by PeriodTExercises.
            NavigationLink(value: program) {
                PrimaryButtonLabel(title: "Start", style: .filled)
            }
        }
        .padding(.top, 8)
    }
}


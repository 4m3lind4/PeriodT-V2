//
//  ExpandableProgramCard.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//

import SwiftUI

/// Program summary card that expands to reveal its workouts and a Start button.
/// Expansion is controlled by the parent so only one card is open at a time.
struct ExpandableProgramCard: View {
    let program: ExerciseProgram
    @Binding var expandedProgramID: ExerciseProgram.ID?
    /// Off where there's no exercise NavigationStack to push onto (e.g. the calendar sheet).
    var showsStart = true

    private var isExpanded: Bool { expandedProgramID == program.id }

    var body: some View {
        VStack(spacing: 0) {
            header

            if isExpanded {
                workoutList
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        // When open, the header sits on a pale tray that holds the workouts and Start.
        .background(CoreColor.cardTray.opacity(isExpanded ? 1 : 0))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(isExpanded ? 0.06 : 0), radius: 8, y: 2)
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
        // Lifts the header off the tray when open.
        .shadow(color: .black.opacity(isExpanded ? 0.12 : 0), radius: 6, y: 3)
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

    private let thumbnailSize: CGFloat = 76
    private let rowSpacing: CGFloat = 16

    /// Workouts lined up with the header text, divided by faint lines, then Start.
    private var workoutList: some View {
        VStack(spacing: 0) {
            ForEach(program.workouts) { workout in
                WorkoutRow(workout: workout, thumbnailSize: thumbnailSize, spacing: rowSpacing)
                    .padding(.vertical, 14)

                if workout.id != program.workouts.last?.id {
                    // Starts where the thumbnail ends, as in the design.
                    Rectangle()
                        .fill(CoreColor.primary.opacity(0.3))
                        .frame(height: 1)
                        .padding(.leading, thumbnailSize)
                }
            }

            if showsStart {
                // Pushes onto the NavigationStack owned by PeriodTExercises.
                NavigationLink(value: program) {
                    PrimaryButtonLabel(title: "Start", style: .filled)
                }
                .padding(.top, 12)
            }
        }
        // Indent matches the header text, which sits past the status stripe.
        .padding(.leading, stripeWidth + (isPhysio ? physioWidth : 0) + 16)
        .padding(.trailing, 24)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}


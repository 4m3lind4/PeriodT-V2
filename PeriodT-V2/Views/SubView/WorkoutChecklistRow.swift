//
//  WorkoutChecklistRow.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Light pink row with a tickable box, used while a program is in progress.
struct WorkoutChecklistRow: View {
    let workout: Workout
    
    @Binding var isChecked: Bool

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CoreColor.white)
                        .frame(width: 56, height: 56)
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(CoreColor.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    if let sets = workout.sets {
                        Text("\(sets) Sets")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                }
                .foregroundStyle(CoreColor.primary)
                .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(CoreColor.ringBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var checked = false
    WorkoutChecklistRow(workout: Workout(name: "Squat - BB", sets: 4), isChecked: $checked)
        .padding()
        .background(CoreColor.primary)
}

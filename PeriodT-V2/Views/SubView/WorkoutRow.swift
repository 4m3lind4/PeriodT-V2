//
//  WorkoutRow.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//


//
//  WorkoutRow.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
import SwiftUI

struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        VStack(spacing: 4) {
            Text(workout.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            if let sets = workout.sets {
                Text("\(sets) Sets")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
        }
        .foregroundStyle(CoreColor.primary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(CoreColor.ringBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.12), radius: 0, y: 3)
    }
}

#Preview {
    WorkoutRow(workout: Workout(name: "run"))
}

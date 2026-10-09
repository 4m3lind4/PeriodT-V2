//
//  WorkoutProgressCard.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 10/10/2026.
//

import SwiftUI

/// Pale pink exercise card on the in-progress program list. Tapping it opens the set tracker.
struct WorkoutProgressCard: View {
    let workout: Workout

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ExerciseThumbnail(url: workout.imageURL, size: 84)

            VStack(alignment: .leading, spacing: 0) {
                Text(workout.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                if let sets = workout.sets {
                    Text("\(sets) Sets")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .opacity(0.85)
                }
            }
            .foregroundStyle(CoreColor.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.vertical, 4)
        }
        .frame(height: 84)
        .padding(10)
        .background(CoreColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    VStack {
        WorkoutProgressCard(workout: Workout(name: "Lunge with scooter - rowing machine", sets: 3))
        WorkoutProgressCard(workout: Workout(name: "Walking"))
    }
    .padding()
    .background(CoreColor.primary)
}

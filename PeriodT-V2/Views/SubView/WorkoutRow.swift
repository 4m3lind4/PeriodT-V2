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

/// One exercise in an expanded program: thumbnail, name, then sets on the right.
struct WorkoutRow: View {
    let workout: Workout
    var thumbnailSize: CGFloat = 76
    var spacing: CGFloat = 16

    var body: some View {
        HStack(spacing: spacing) {
            ExerciseThumbnail(url: ExerciseImageCatalog.imageURL(for: workout.name), size: thumbnailSize)

            Text(workout.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let sets = workout.sets {
                Text("\(sets) sets")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(CoreColor.primary.opacity(0.75))
                    .fixedSize()
            }
        }
        .foregroundStyle(CoreColor.primary)
    }
}

#Preview {
    VStack {
        WorkoutRow(workout: Workout(name: "Lunge with scooter - rowing machine", sets: 3))
        WorkoutRow(workout: Workout(name: "Plank"))
    }
    .padding()
    .background(CoreColor.cardTray)
}

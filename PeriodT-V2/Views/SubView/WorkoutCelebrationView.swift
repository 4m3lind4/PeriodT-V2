//
//  WorkoutCelebrationView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Full-screen confetti overlay shown after the post-workout quiz is submitted.
/// Uses the pink brand background so the confetti (lavender / pale pink / orange)
/// reads on-brand, then hands control back via `onFinished`.
struct WorkoutCelebrationView: View {
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            CoreColor.primary
                .ignoresSafeArea()

    
            VStack(spacing: 6) {
                LottieView(animationName: "Confestti", speed: 1.2, onFinished: onFinished)
                    .frame(width: 550, height: 550)
                    .padding(.bottom, 12)

                Text("Workout Logged")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Nice work!")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(CoreColor.ringBackground)
            }
            .padding(.bottom, 60)
        }
        .transition(.opacity)
    }
}

#Preview {
    WorkoutCelebrationView(onFinished: {})
}

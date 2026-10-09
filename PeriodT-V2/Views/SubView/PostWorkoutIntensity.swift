//
//  PostWorkoutIntensity.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Five-step "how hard was it" slider (0 = too hard, 4 = too easy).
/// Styled for the pink completed-program screen.
struct PostWorkoutIntensity: View {
    @State var selectedIntensity: Int = 2

    var body: some View {
        StepSliderView(
            title: "Workout Intensity",
            lowLabel: "TOO HARD",
            highLabel: "TOO EASY",
            textColor: CoreColor.ringBackground,
            thumbColor: CoreColor.lavender,
            selectedStep: $selectedIntensity
        )
    }
}

#Preview {
    PostWorkoutIntensity()
        .padding()
        .background(CoreColor.primary)
}

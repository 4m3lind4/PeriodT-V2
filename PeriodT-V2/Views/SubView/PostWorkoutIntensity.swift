//
//  PostWorkoutIntensity.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  The "how hard was it" slider on the completed-program screen.
//

import SwiftUI

/// 0 is too hard and 4 is too easy. Coloured for the pink background.
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

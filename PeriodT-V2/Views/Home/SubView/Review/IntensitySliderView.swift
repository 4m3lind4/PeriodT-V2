//
//  IntensitySliderView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The "how pleasant did today feel" slider in the daily check-in.
//

import SwiftUI

/// Goes from very unpleasant (0) to very pleasant (4).
struct IntensitySliderView: View {
    /// The middle of the track, shown until the athlete picks something.
    static let defaultIntensity = 2

    @Binding var selectedIntensity: Int

    var body: some View {
        StepSliderView(
            title: "Emotional Intensity",
            lowLabel: "VERY UNPLEASANT",
            highLabel: "VERY PLEASANT",
            selectedStep: $selectedIntensity
        )
    }
}

#Preview {
    @Previewable @State var intensity = IntensitySliderView.defaultIntensity
    IntensitySliderView(selectedIntensity: $intensity)
        .padding()
}

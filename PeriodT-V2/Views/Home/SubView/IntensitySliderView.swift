//
//  IntensitySliderView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Five-step "how pleasant" slider, from very unpleasant (0) to very pleasant (4).
struct IntensitySliderView: View {
    /// Middle of the track, shown until the user picks a value.
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

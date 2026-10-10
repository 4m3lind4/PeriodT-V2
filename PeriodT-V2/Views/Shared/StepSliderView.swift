//
//  StepSliderView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//
//  A five-step slider used for both the emotional intensity and workout
//  intensity questions. It's custom rather than a system Slider so it snaps to
//  each step.
//

import SwiftUI

struct StepSliderView: View {
    static let steps = 5

    let title: String
    let lowLabel: String
    let highLabel: String
    /// Colour for the title and end labels.
    var textColor: Color = CoreColor.primary
    /// Colour of the draggable thumb.
    var thumbColor: Color = CoreColor.primary

    @Binding var selectedStep: Int

    private let trackHeight: CGFloat = 20
    private let thumbSize: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Font.system(size: 20, design: .rounded))
                .foregroundColor(textColor)

            track
                .frame(height: thumbSize)

            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(Font.system(size: 16, design: .rounded))
            .foregroundColor(textColor)
        }
    }

    /// The track, a dot for each step and the thumb sitting over whichever step is picked.
    private var track: some View {
        GeometryReader { geo in
            // Split the track into equal steps and sit the thumb in the middle of its one.
            let stepWidth = geo.size.width / CGFloat(Self.steps)
            let thumbX = stepWidth * (CGFloat(selectedStep) + 0.5)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(CoreColor.ringBackground)
                    .frame(height: trackHeight)
                    .shadow(color: .black.opacity(0.15), radius: 0, y: 3)

                HStack(spacing: 0) {
                    ForEach(0..<Self.steps, id: \.self) { _ in
                        Circle()
                            .fill(CoreColor.primary)
                            .frame(width: 10, height: 10)
                            .frame(maxWidth: .infinity)
                    }
                }

                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .position(x: thumbX, y: geo.size.height / 2)
            }
            .contentShape(Rectangle())
            // Tap or drag anywhere on the track and it snaps to the closest step.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let index = Int(value.location.x / stepWidth)
                        selectedStep = min(max(index, 0), Self.steps - 1)
                    }
            )
            .animation(.snappy(duration: 0.2), value: selectedStep)
        }
        // VoiceOver can't use a drag gesture, so expose it as an adjustable control
        // instead (swipe up/down to change it).
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityValue("\(selectedStep + 1) of \(Self.steps)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selectedStep = min(selectedStep + 1, Self.steps - 1)
            case .decrement: selectedStep = max(selectedStep - 1, 0)
            @unknown default: break
            }
        }
    }
}

#Preview {
    @Previewable @State var step = 2
    StepSliderView(
        title: "Emotional Intensity",
        lowLabel: "VERY UNPLEASANT",
        highLabel: "VERY PLEASANT",
        selectedStep: $step
    )
    .padding()
}

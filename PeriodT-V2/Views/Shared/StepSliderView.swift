//
//  StepSliderView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// Generic five-step slider with a title and end labels.
/// Used for both the emotional-intensity and workout-intensity questions.
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

    /// Capsule track, one dot per step, and the thumb positioned over the selected step.
    private var track: some View {
        GeometryReader { geo in
            // Divide the track into equal steps; thumb sits in the middle of its step.
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
            // Tap or drag anywhere on the track to snap to the nearest step.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let index = Int(value.location.x / stepWidth)
                        selectedStep = min(max(index, 0), Self.steps - 1)
                    }
            )
            .animation(.snappy(duration: 0.2), value: selectedStep)
        }
        // The drag gesture isn't reachable with VoiceOver, so expose it as an adjustable control.
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

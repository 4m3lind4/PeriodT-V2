//
//  EmotionButton.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  One tappable face in the mood picker.
//

import SwiftUI

struct EmotionButton: View {
    let emotion: Emotion
    @Binding var selectedEmotion: Emotion?

    private var isSelected: Bool { selectedEmotion == emotion }

    var body: some View {
        Button(action: { selectedEmotion = emotion }) {
            Image(emotion.image)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
        }
        .padding(10)
        .background(isSelected ? CoreColor.primary.opacity(0.35) : CoreColor.ringBackground)
        .clipShape(Circle())
        .accessibilityLabel(emotion.rawValue.capitalized)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selected: Emotion? = .sad
    EmotionButton(emotion: .sad, selectedEmotion: $selected)
}

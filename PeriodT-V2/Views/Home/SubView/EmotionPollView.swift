//
//  EmotionPollView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Row of five emotion faces; only one can be selected.
struct EmotionPollView: View {
    @Binding var selectedEmotion: Emotion?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Emotional")
            .font(Font.system(size: 20, design: .rounded))
            .foregroundColor(CoreColor.primary)
            
            Spacer(minLength: 20)
                
            HStack(spacing: 0) {
                ForEach(Emotion.allCases) { emotion in
                    EmotionButton(emotion: emotion, selectedEmotion: $selectedEmotion)
                        .frame(maxWidth: .infinity)   // share the row evenly, never overflow
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Emotion? = .calm
    EmotionPollView(selectedEmotion: $selected)
}

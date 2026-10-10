//
//  EmotionPollView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The row of five mood faces in the daily check-in.
//

import SwiftUI

/// Only one can be picked at a time.
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
                        .frame(maxWidth: .infinity)   // share the row evenly so it never overflows
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Emotion? = .calm
    EmotionPollView(selectedEmotion: $selected)
}

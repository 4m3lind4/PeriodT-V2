//
//  QuestionCardView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI


/// Coloured question banner with a Yes / No button row underneath.
/// The chosen answer is highlighted and written back through the binding.

struct QuestionCardView: View {
    @Binding var selectedAnswer: ReviewAnswer?
    var question: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            Text(question)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)   // never truncate
                .padding(.vertical, 40)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .background(color)
            
            
            HStack(spacing: 0) {
                Button {
                    selectedAnswer = .yes
                } label: {
                    Text("Yes")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(CoreColor.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedAnswer == .yes ? Color.orange.opacity(0.3) : Color.clear)
                }
                .accessibilityAddTraits(selectedAnswer == .yes ? .isSelected : [])

                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 1)

                Button {
                    selectedAnswer = .no
                } label: {
                    Text("No")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(CoreColor.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedAnswer == .no ? Color.orange.opacity(0.3) : Color.clear)
                }
                .accessibilityAddTraits(selectedAnswer == .no ? .isSelected : [])
            }
            .background(CoreColor.ringBackground)
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
    }
    
}


#Preview {
    @Previewable @State var answer: ReviewAnswer? = nil
    QuestionCardView(
        selectedAnswer: $answer,
        question: "Did you practice or train today?",
        color: CoreColor.primary
    )
}

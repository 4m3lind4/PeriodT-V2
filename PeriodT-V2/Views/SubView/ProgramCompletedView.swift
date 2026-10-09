//
//  ProgramCompletedView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 8/10/2026.
//

import SwiftUI

/// "Great Job" screen shown after a program is submitted.
struct ProgramCompletedView: View {
    @EnvironmentObject private var navigation: AppNavigationViewModel

    @State private var informCoach: ReviewAnswer?
    @State private var showCelebration = false

    var body: some View {
        ZStack{
            CoreColor.primary
                .ignoresSafeArea()
            ScrollView {
            VStack(alignment: .leading, spacing: 16){
                Text("Great Job!")
                    .font(Font.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                PostWorkoutIntensity()
                WorkoutJournalView()

                QuestionCardView(
                    selectedAnswer: $informCoach,
                    question: "Would you like to inform your coach about your set?",
                    color: CoreColor.accent
                )
                .padding(.horizontal, 8)

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCelebration = true
                    }
                } label: {
                    PrimaryButtonLabel(title: "Submit")
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding(10)
            }

            if showCelebration {
                WorkoutCelebrationView {
                    navigation.returnHome()
                }
                .zIndex(1)
            }
        }
        .toolbar(showCelebration ? .hidden : .visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ProgramCompletedView()
    }
    .environmentObject(AppNavigationViewModel())
}

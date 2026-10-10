//
//  QuickQuestionaireView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI

/// "Review" section on Home - the daily poll for today.
struct HomeQuestionaireView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(CoreColor.primary)

            DayPollView(day: .now)
        }
    }
}

#Preview {
    HomeQuestionaireView()
        .previewTrackingStore()
}

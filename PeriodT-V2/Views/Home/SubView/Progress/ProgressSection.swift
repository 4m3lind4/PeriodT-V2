//
//  ProgressSection.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI

/// "My Progress" section showing a single hard-coded goal and its progress bar.
struct ProgressSection: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("My Progress")
                .font(Font.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(CoreColor.primary)
                .padding(.horizontal, 12)
            
            VStack(alignment: .center, spacing: 12){
                Text("Goal 1")
                    .font(Font.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(CoreColor.primary)
                    .padding(.horizontal, 12)
                Text("Complete physio exercsies for mobility")
                    .multilineTextAlignment(.center)
                    .padding(1)
                    .foregroundStyle(CoreColor.primary)
                GoalProgressBar()
                Text("20% Completed")
                    .multilineTextAlignment(.center)
                    .padding(1)
                    .foregroundStyle(CoreColor.primary)
                    .bold(true)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(CoreColor.ringBackground)
            }

        }
 
    }
}

#Preview {
    ProgressSection()
}

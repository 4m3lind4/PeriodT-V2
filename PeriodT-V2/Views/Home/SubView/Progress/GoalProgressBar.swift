//
//  GoalProgressBar.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI

struct GoalProgressBar: View {
    var body: some View {
          VStack(spacing: 20) {
              ProgressView(value: 0.2)
                  .padding()
                  .frame(width: 300)
                  .scaleEffect(x: 1, y: 3, anchor: .center)
                  .tint(CoreColor.accent)
                  .clipShape(RoundedRectangle(cornerRadius: 10))

          }
      }
}

#Preview {
    GoalProgressBar()
}

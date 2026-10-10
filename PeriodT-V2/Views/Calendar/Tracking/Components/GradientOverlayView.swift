//
//  GradientOverlayView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The soft purple fade at the bottom of the Calendar tab.
//

import SwiftUI

/// Pinned to the screen rather than the calendar, so it looks the same however many
/// months there are. It ignores touches so the days underneath can still be tapped.
struct GradientOverlayView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.35),
                    .init(
                        color: CoreColor.secondary.opacity(0.08),
                        location: 0.55
                    ),
                    .init(
                        color: CoreColor.secondary.opacity(0.30),
                        location: 1.0
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

    
        }
    }
}

#Preview {
    GradientOverlayView()
}

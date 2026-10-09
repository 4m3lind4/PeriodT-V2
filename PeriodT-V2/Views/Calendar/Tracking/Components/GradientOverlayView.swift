//
//  GradientOverlayView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Wraps the calendar in a purple fade toward the bottom of the screen.
/// The gradient ignores touches so the days underneath stay tappable.
struct GradientOverlayView: View {
    var body: some View {
        ZStack {
            
            CalendarView(calendarViewModel: CalendarViewModel())
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
        .errorCardHost()
}

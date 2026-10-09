//
//  DayDetailSheet.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI
import SwiftData

/// Semi-transparent pink sheet shown when a calendar day is tapped,
/// letting the user review and change that day's poll answers.
struct DayDetailSheet: View {
    let day: Date

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundColor(CoreColor.primary)

                DayPollView(day: day)
            }
            .padding()
            .padding(.top, 8)
        }
        .scrollIndicators(.hidden)
        // Sheets sit above the calendar's host, so errors need their own.
        .errorCardHost()
        .presentationDetents([.fraction(0.8), .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(CoreColor.ringBackground.opacity(0.85))
    }
}

#Preview {
    Color.white
        .sheet(isPresented: .constant(true)) {
            DayDetailSheet(day: .now)
        }
        .modelContainer(for: PollAnswers.self, inMemory: true)
}

//
//  CycleRingView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//

import SwiftUI

/// Hosts the cycle ring and animates it to today's point in the cycle.
/// Uses the same period-due maths as the Calendar header so the two always agree.
struct CycleRingView: View {
    @EnvironmentObject private var store: TrackingStore
    @State var progressValue: Float = 0.0

    private let periodDue = PeriodDueViewModel()

    var body: some View {
        VStack{
            CycleProgressRing(
                progress: self.$progressValue,
                daysUntilPeriod: periodDue.daysUntilNextPeriod(in: store.allReviews),
                phase: periodDue.phase(in: store.allReviews)
            )
                .frame(width: 260.0, height: 260)
                .padding(20.0)
                .onAppear { updateProgress() }
                // New or edited poll answers can move the due date.
                .onChange(of: periodDue.cycleProgress(in: store.allReviews)) { _, _ in updateProgress() }
        }
    }

    private func updateProgress() {
        progressValue = Float(periodDue.cycleProgress(in: store.allReviews))
    }
}


#Preview {
    CycleRingView()
        .previewTrackingStore()
}

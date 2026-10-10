//
//  CycleRingView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//
//  Feeds the cycle ring its numbers from the store and animates it to today.
//

import SwiftUI

/// Uses the same PeriodDueViewModel maths as the calendar so the two never disagree.
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
                // Logging or editing a period can move the due date, so re-animate.
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

//
//  FutureDayErrorView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The error card for tapping a day that hasn't happened yet.
//

import SwiftUI

/// Just a thin wrapper around the shared `ErrorCardView`.
struct FutureDayErrorView: View {
    let day: Date
    let onDismiss: () -> Void

    var body: some View {
        ErrorCardView(error: .futureDay(day), onDismiss: onDismiss)
    }
}

#Preview {
    FutureDayErrorView(day: .now) {}
        .padding()
}

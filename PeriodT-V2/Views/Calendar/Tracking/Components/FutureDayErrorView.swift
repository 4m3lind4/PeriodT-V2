//
//  FutureDayErrorView.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Pink error card shown when the user taps a day that hasn't happened yet.
/// Thin wrapper over the shared `ErrorCardView`.
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

//
//  PrimaryButtonLabel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//
//  The rounded button style used for Submit, Start and Save across the app.
//

import SwiftUI

/// Only the label, so wrap it in a `Button` or `NavigationLink` to make it tappable.
struct PrimaryButtonLabel: View {
    enum Style {
        /// Pink text on a pale background, for coloured screens.
        case light
        /// White text on a pink background, for white screens.
        case filled
        /// Light pink text on pink, a softer version of `filled`.
        case filledSoft
    }

    private var textColor: Color {
        switch style {
        case .light: CoreColor.primary
        case .filled: .white
        case .filledSoft: CoreColor.ringBackground
        }
    }

    let title: String
    var style: Style = .light

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, 40)
            .padding(.vertical, 10)
            .background(style == .light ? CoreColor.ringBackground : CoreColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .black.opacity(0.2), radius: 0, y: 3)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButtonLabel(title: "Submit")
        PrimaryButtonLabel(title: "Submit", style: .filledSoft)
        PrimaryButtonLabel(title: "Start", style: .filled)
    }
    .padding()
    .background(CoreColor.primary.opacity(0.3))
}

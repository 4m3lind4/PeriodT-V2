//
//  PrimaryButtonLabel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 5/10/2026.
//


//
//  PrimaryButton.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Large rounded call-to-action label (Submit / Start).
/// Wrap it in a `Button` or `NavigationLink` to make it tappable.
struct PrimaryButtonLabel: View {
    enum Style {
        /// Pink text on a pale background - for use on coloured screens.
        case light
        /// White text on a pink background - for use on white screens.
        case filled
    }

    let title: String
    var style: Style = .light

    var body: some View {
        Text(title)
            .font(.system(size: 26, weight: .bold, design: .rounded))
            .foregroundStyle(style == .light ? CoreColor.primary : .white)
            .padding(.horizontal, 40)
            .padding(.vertical, 12)
            .background(style == .light ? CoreColor.ringBackground : CoreColor.primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.2), radius: 0, y: 3)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButtonLabel(title: "Submit")
        PrimaryButtonLabel(title: "Start", style: .filled)
    }
    .padding()
    .background(CoreColor.primary.opacity(0.3))
}

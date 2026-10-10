//
//  PhaseLegendChip.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI

/// Small coloured pill naming one cycle phase, shown under the forecast chart.
struct PhaseLegendChip: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
            )
    }
}

#Preview {
    HStack {
        PhaseLegendChip(title: "Menstruation", color: CoreColor.primary)
        PhaseLegendChip(title: "Luteal", color: CoreColor.secondary)
    }
}

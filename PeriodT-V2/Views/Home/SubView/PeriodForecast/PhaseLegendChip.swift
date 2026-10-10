//
//  PhaseLegendChip.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//
//  A small coloured pill naming one cycle phase, used under the forecast chart.
//

import SwiftUI

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

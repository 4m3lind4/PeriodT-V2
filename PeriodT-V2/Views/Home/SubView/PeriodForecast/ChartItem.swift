//
//  ChartItem.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//

import SwiftUI


/// "Period Forecast" section: explanatory text, the emotion line chart,
/// and a legend of the four cycle phases.
struct ChartItem: View {
    
    var body: some View {
        //HEADING
        VStack(alignment: .leading, spacing: 1){
            Text("Period Forecast")
                .font(Font.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(CoreColor.primary)
                .padding(.horizontal, 12)

            //FIRST BODY OF TECT
            VStack(alignment: .center, spacing: 12) {
                Text("By being in the luteal phase you should expect to feeling emotionally intense in practice due to PMS.")
                    .multilineTextAlignment(.center)
                    .padding(1)
                    .foregroundStyle(CoreColor.primary)
                    .font(.body)
                Text("Your Emotional States")
                    .font(Font.system(size: 16, weight: .bold, design: .rounded))
                    .padding(-5)
                    .foregroundColor(CoreColor.primary)
                

                ChartView()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CoreColor.white)
                    }
                phaseLegend
                
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(CoreColor.ringBackground)
            }
        }
    }

    /// One chip per cycle phase, coloured to match the chart.
    private var phaseLegend: some View {
        HStack {
            PhaseLegendChip(title: "Menstruation", color: CoreColor.primary)
            PhaseLegendChip(title: "Follicular", color: CoreColor.accent)
            PhaseLegendChip(title: "Ovulation", color: CoreColor.yellow)
            PhaseLegendChip(title: "Luteal", color: CoreColor.secondary)
        }
    }
}

#Preview {
    ChartItem()
}


//
//  ChartView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 13/9/2026.
//
//  Line chart comparing how emotionally intense the week feels in two phases.
//  It's still sample data for now, the plan is to build it from real check-ins.
//

import SwiftUI
import Charts

struct ChartView: View {
    let data: [EmotionalLevel] = [
        EmotionalLevel(day: "Mon", menstrualLevel: 10, lutealLevel: 20),
        EmotionalLevel(day: "Tue", menstrualLevel: 25, lutealLevel: 20),
        EmotionalLevel(day: "Wed", menstrualLevel: 15, lutealLevel: 20),
        EmotionalLevel(day: "Thu", menstrualLevel: 40, lutealLevel: 20),
        EmotionalLevel(day: "Fri", menstrualLevel: 30, lutealLevel: 20),
        EmotionalLevel(day: "Sat", menstrualLevel: 40, lutealLevel: 20),
        EmotionalLevel(day: "Sun", menstrualLevel: 30, lutealLevel: 20)
    ]

    var body: some View {
        Chart(data) { item in
            // One line per phase. The colours get mapped in chartForegroundStyleScale below.
            LineMark(
                x: .value("Day", item.day),
                y: .value(
                    "Emotional level",
                    item.menstrualLevel
                )
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                by: .value("Cycle phase", "Menstrual")
            )

            LineMark(
                x: .value("Day", item.day),
                y: .value(
                    "Emotional level",
                    item.lutealLevel
                )
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                by: .value("Cycle phase", "Luteal")
            )
        }
        .chartForegroundStyleScale([
            "Menstrual": CoreColor.primary,
            "Luteal": CoreColor.secondary
        ])
        
        .frame(height: 200)
        .padding(10)
    }
}

#Preview {
    ChartView()
        .padding()
}

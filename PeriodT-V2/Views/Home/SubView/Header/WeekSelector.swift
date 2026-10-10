//
//  WeekSelector.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import SwiftUI

/// Monday–Sunday strip for the current week with today highlighted.
struct WeekSelector: View {
    
    var weekSelectorViewModel = WeekSelectorViewModel()

    var body: some View {

        HStack(spacing: 0) {

            ForEach(weekSelectorViewModel.days) { item in

                VStack(spacing: 12) {

                    Text(item.day)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("\(item.date)")
                        .font(.system(size: 22))
                }
                .foregroundStyle(
                    weekSelectorViewModel.currentDateNumber == item.date
                    ? Color.white
                    : CoreColor.primary
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                // Filled pill behind today's date only.
                .background(
                    Group {
                        if weekSelectorViewModel.currentDateNumber == item.date {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(CoreColor.primary)
                        }
                    }
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CoreColor.ringBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
    

}



#Preview {
    WeekSelector()
}

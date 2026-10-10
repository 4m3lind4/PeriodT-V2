//
//  UpcomingEventCapsule.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 12/9/2026.
//

import SwiftUI

struct UpcomingEventCapsule: View {
    var title:String
    var daysRemaining:Int
    
    var body: some View {
        VStack(spacing:0){
            Text("Upcoming Event...")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.vertical, 1)
                .background(CoreColor.primary)

            HStack{
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)

                Spacer()
                Text("\(daysRemaining) Days")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(CoreColor.accent)
        }
        .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
    }
}

#Preview {
    UpcomingEventCapsule( title: "Event", daysRemaining: 45)
}

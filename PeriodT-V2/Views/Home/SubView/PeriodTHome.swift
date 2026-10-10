//
//  PeriodTHome.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//
//  The Home tab. It's mostly a stack of sections (week strip, cycle ring,
//  forecast, today's programs, progress and the daily check-in), each in its own
//  file so this one just lays them out.
//

import SwiftUI

struct PeriodTHome: View {
    @EnvironmentObject private var store: TrackingStore

    private let viewModel = WeekSelectorViewModel()

    /// Where Submit scrolls back to.
    private let topID = "home-top"

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView{
            VStack(spacing:1){
                greetingHeader
                    .padding(.horizontal,10)
                    .id(topID)

                WeekSelector()
                Spacer()
                UpcomingEventCapsule( title: "National Team Selection", daysRemaining: 45)
                Spacer()
                CycleRingView()
                    .padding(30)
                ChartItem()
                Spacer()
                ProgramViews(programs: store.programs(on: Date()))
                    .padding(.horizontal,-20)
                ProgressSection()
                Spacer()
                HomeQuestionaireView()

                // Answers already save as they're picked, so Submit doesn't actually save
                // anything. It just gives a sense of being done and scrolls back to the top.
                Button {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(topID, anchor: .top)
                    }
                } label: {
                    PrimaryButtonLabel(title: "Submit", style: .filledSoft)
                }
                .padding(.top, 16)

            }
            .padding(10)
        }
        // Stops Submit hiding behind the floating tab bar.
        .contentMargins(.bottom, 100, for: .scrollContent)
        }
    }
    

    /// "Good Morning, <name>" plus today's date, with the profile icon.
    private var greetingHeader: some View {
        ScreenHeader {
            VStack(alignment: .leading){
                Text ("Good Morning!")
                    .font(Font.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(CoreColor.primary)

                Text ("Beth")
                    .font(Font.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(CoreColor.primary)

                Text ("Today, \(viewModel.currentDateNumber) \(viewModel.currentMonthName)")
                    .font(.body)
                    .foregroundColor(CoreColor.primary)
            }
        }
    }

}




#Preview {
    PeriodTHome()
        .previewTrackingStore()
}


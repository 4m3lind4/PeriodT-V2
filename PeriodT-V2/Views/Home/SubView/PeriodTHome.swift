//
//  PeriodTHome.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 11/9/2026.
//

import SwiftUI

/// Home tab: greeting, week strip, cycle ring, forecast chart,
/// program carousel, goal progress and the daily review poll.
struct PeriodTHome: View {
    let repository: IPeriodTRepository
    @State private var programs: [ExerciseProgram] = []

    private let viewModel = WeekSelectorViewModel()

    /// Scroll target for Submit to jump back to.
    private let topID = "home-top"

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView{
            VStack(spacing:1){
                greetingHeader
                    .padding(.horizontal,10)
                    .id(topID)
// MARK: ------ COMPLIATION OF ITEMS

                WeekSelector()
                Spacer()
                UpcomingEventCapsule( title: "National Team Selection", daysRemaining: 45)
                Spacer()
                CycleRingView()
                    .padding(30)
                ChartItem()
                Spacer()
                ProgramViews(programs: programs)                    .padding(.horizontal,-20)
                ProgressSection()
                Spacer()
                HomeQuestionaireView()

                // Answers already save as they're picked; Submit just confirms
                // and takes the user back up to the top of Home.
                Button {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(topID, anchor: .top)
                    }
                } label: {
                    PrimaryButtonLabel(title: "Submit")
                }
                .padding(.top, 16)
            }
            .padding(10)
        }
        // Keeps Submit clear of the floating tab bar.
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
    
    private func load() async {
        do {
            programs = try await repository.fetchWorkouts()
        } catch {
            print("Failed to load programs: \(error)")
        }
    }

}




#Preview {
    PeriodTHome(repository: MockPeriodTRepository())
}


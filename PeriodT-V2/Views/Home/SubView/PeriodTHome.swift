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

    var body: some View {
        ScrollView{
            VStack(spacing:1){
                greetingHeader
                    .padding(.horizontal,10)
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

            }
            .padding(10)
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


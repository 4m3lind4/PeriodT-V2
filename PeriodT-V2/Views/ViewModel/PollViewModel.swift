//
//  PollViewModel.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//
//  The list of yes/no questions asked in the daily check-in on Home.
//

import Foundation
import Combine

final class DayPoleModel: ObservableObject {
    @Published var questions: [PollQuestion] = [
        PollQuestion(kind: .trained, text: "Did you practice or train today?", color: CoreColor.secondary),
        PollQuestion(kind: .onPeriod, text: "Were you on your period?", color: CoreColor.secondary),
        PollQuestion(kind: .informCoachPeriod, text: "Would you like to inform your coach about your period?", color: CoreColor.secondary),
        PollQuestion(kind: .informCoachWorkout, text: "Would you like to update your coach about your Workout?", color: CoreColor.secondary)
    ]
}

//
//  IPeriodTReposity.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import Foundation

protocol IPeriodTRepository {
    func fetchWorkouts() async throws -> [ExerciseProgram]
    func addProgram(_ program: ExerciseProgram) async throws
}

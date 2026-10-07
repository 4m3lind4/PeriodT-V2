//
//  ContentView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 1/10/2026.
//

import SwiftUI

/// Temporary screen that proves programs load from Supabase.
struct ContentView: View {
    let repository: IPeriodTRepository

    @State private var programs: [ExerciseProgram] = []
    @State private var errorMessage: String?
    @State private var isAddingProgram = false

    var body: some View {
        NavigationStack {
            List(programs) { program in
                Section("\(program.formattedDate) · \(program.exerciseType.title)") {
                    ForEach(program.workouts) { workout in
                        HStack {
                            ExerciseThumbnail(url: workout.imageURL)
                            Text(workout.name)
                            Spacer()
                            if let sets = workout.sets {
                                Text("\(sets) sets").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .overlay {
                if let errorMessage {
                    ContentUnavailableView("Couldn't load programs", systemImage: "wifi.exclamationmark", description: Text(errorMessage))
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                Button("Add Program", systemImage: "plus") { isAddingProgram = true }
            }
            .sheet(isPresented: $isAddingProgram) {
                AddProgramView(repository: repository, onSaved: load)
            }
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        do {
            programs = try await repository.fetchWorkouts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView(repository: MockPeriodTRepository())
}

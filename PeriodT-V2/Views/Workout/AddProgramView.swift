//
//  AddProgramView.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import SwiftUI

/// Form for entering a new exercise program and saving it to Supabase.
struct AddProgramView: View {
    let repository: IPeriodTRepository
    /// Called after a successful save so the list can refresh.
    var onSaved: () async -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var day = 1
    @State private var exerciseDuration = 30
    @State private var exerciseType: ExerciseType = .physio
    @State private var workouts: [Workout] = [Workout(name: "", sets: 3)]
    
    /// Kept across Save taps, so retrying after a failed save completes the same
    /// program rather than creating a second one.
    @State private var programID = UUID()
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    private var canSave: Bool {
        !isSaving && workouts.contains { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Program") {
                    DatePicker("Date", selection: $date)
                    Picker("Type", selection: $exerciseType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    Stepper("Day \(day)", value: $day, in: 1...365)
                    Stepper("\(exerciseDuration) min", value: $exerciseDuration, in: 5...240, step: 5)
                }
                
                Section("Workouts") {
                    ForEach($workouts) { $workout in
                        HStack {
                            TextField("Exercise name", text: $workout.name)
                            Spacer()
                            Stepper(setsLabel(workout.sets), value: setsBinding($workout), in: 0...20)
                                .fixedSize()
                        }
                    }
                    .onDelete { workouts.remove(atOffsets: $0) }
                    
                    Button("Add Workout", systemImage: "plus") {
                        workouts.append(Workout(name: "", sets: 3))
                    }
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { Task { await save() } }
                            .disabled(!canSave)
                    }
                }
            }
        }
    }
    
    private func save() async {
        isSaving = true
        defer { isSaving = false }
        
        let namedWorkouts = workouts
            .map { Workout(id: $0.id, name: $0.name.trimmingCharacters(in: .whitespaces), sets: $0.sets) }
            .filter { !$0.name.isEmpty }
        
        let program = ExerciseProgram(
            id: programID,
            date: date,
            day: day,
            exerciseDuration: exerciseDuration,
            numberOfExercises: namedWorkouts.count,
            exerciseType: exerciseType,
            workouts: namedWorkouts
        )
        
        do {
            try await repository.addProgram(program)
            await onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 0 sets means "untracked", stored as nil.
    private func setsBinding(_ workout: Binding<Workout>) -> Binding<Int> {
        Binding(
            get: { workout.wrappedValue.sets ?? 0 },
            set: { workout.wrappedValue.sets = $0 == 0 ? nil : $0 }
        )
    }
    
    private func setsLabel(_ sets: Int?) -> String {
        sets.map { "\($0) sets" } ?? "No sets"
    }
}

#Preview {
    AddProgramView(repository: MockPeriodTRepository(delay: .seconds(1)), onSaved: {})
}

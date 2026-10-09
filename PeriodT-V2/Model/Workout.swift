//
//  Workout.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

//
//  Workout.swift
//  PeriodT
//
//  Created by Jessica Amelinda Mang on 14/9/2026.
//

import Foundation

/// One exercise inside a program. `sets` is optional for timed/untracked work.
struct Workout: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var sets: Int?
    var reps: Int?
    var restSeconds: Int?
    /// Whether the signed-in user has ticked this off. Stored in Supabase's
    /// `workout_completions` table, which is per user because programs can be shared.
    var isCompleted = false

    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps
        case restSeconds = "rest_seconds"
        case completions = "workout_completions"
    }

    /// Only `completed_at` is selected; the row existing is what matters.
    private struct Completion: Codable {
        let completedAt: Date

        enum CodingKeys: String, CodingKey {
            case completedAt = "completed_at"
        }
    }
}

extension Workout {
    /// How many tappable set rows to show. Untracked work still gets one row to tick off.
    var setCount: Int { max(sets ?? 1, 1) }
}

// In an extension so the memberwise init (used by previews and AddProgramView) is kept.
extension Workout {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decodeIfPresent(Int.self, forKey: .sets)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        restSeconds = try container.decodeIfPresent(Int.self, forKey: .restSeconds)
        // RLS only returns the current user's rows, so any row means "done by me".
        let completions = try container.decodeIfPresent([Completion].self, forKey: .completions) ?? []
        isCompleted = !completions.isEmpty
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(sets, forKey: .sets)
        try container.encodeIfPresent(reps, forKey: .reps)
        try container.encodeIfPresent(restSeconds, forKey: .restSeconds)
    }
}

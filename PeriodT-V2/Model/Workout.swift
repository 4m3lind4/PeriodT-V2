//
//  Workout.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  A single exercise inside a program, plus whether the signed-in athlete has
//  ticked it off.
//

import Foundation

/// `sets` is optional for things like walking that aren't counted in sets.
struct Workout: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var sets: Int?
    var reps: Int?
    var restSeconds: Int?
    /// Whether the signed-in athlete has ticked this off. Lives in its own
    /// `workout_completions` table because programs are shared, so one athlete
    /// finishing a workout shouldn't tick it for everyone else.
    var isCompleted = false

    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps
        case restSeconds = "rest_seconds"
        case completions = "workout_completions"
    }

    /// Only `completed_at` is fetched. All that matters is whether the row exists.
    private struct Completion: Codable {
        let completedAt: Date

        enum CodingKeys: String, CodingKey {
            case completedAt = "completed_at"
        }
    }
}

extension Workout {
    /// How many set rows to show. Untracked work still gets one row so it can be ticked off.
    var setCount: Int { max(sets ?? 1, 1) }
}

// Custom decoding lives in an extension so Swift still gives me the memberwise init
// (previews and AddProgramView rely on it).
extension Workout {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decodeIfPresent(Int.self, forKey: .sets)
        reps = try container.decodeIfPresent(Int.self, forKey: .reps)
        restSeconds = try container.decodeIfPresent(Int.self, forKey: .restSeconds)
        // RLS only returns the current user's rows, so any row at all means they've done it.
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

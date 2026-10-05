//
//  ExerciseImageCatalog.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//

import Foundation

/// Looks up a photo for an exercise name using `ExerciseImages.csv
enum ExerciseImageCatalog {

    private static let imageURLs: [String: URL] = loadCatalog()

    /// Returns the photo URL for an exercise, or nil if there isn't one.
    static func imageURL(for exerciseName: String) -> URL? {
        imageURLs[key(for: exerciseName)]
    }

    private static func loadCatalog() -> [String: URL] {
        guard let fileURL = Bundle.main.url(forResource: "ExerciseImages", withExtension: "csv"),
              let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return [:]
        }

        var catalog: [String: URL] = [:]
        // Skip the header row
        // go through line by line separating by comma and extract url for each exercise
        for line in contents.split(whereSeparator: \.isNewline).dropFirst() {
            let columns = line.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
            guard columns.count == 2,
                  let url = URL(string: String(columns[1]).trimmingCharacters(in: .whitespaces)),
                  url.scheme != nil else { continue }

            let key = key(for: String(columns[0]))
            if catalog[key] == nil {
                catalog[key] = url
            }
        }
        return catalog
    }

    /// "Farmer's Walk" → "farmerswalk", "Goblet squats" → "gobletsquat".
    private static func key(for name: String) -> String {
        var key = name.lowercased().filter { $0.isLetter || $0.isNumber }
        if key.hasSuffix("s") {
            key.removeLast()
        }
        return key
    }
}

extension Workout {
    var imageURL: URL? {
        ExerciseImageCatalog.imageURL(for: name)
    }
}

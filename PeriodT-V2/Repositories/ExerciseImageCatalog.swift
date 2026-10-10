//
//  ExerciseImageCatalog.swift
//  PeriodT-V2
//
//  Created by Jessica Amelinda Mang on 4/10/2026.
//
//  Matches exercise names to photos using the bundled `ExerciseImages.csv`, so
//  the coach only has to type a name and the thumbnail turns up on its own.
//

import Foundation

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
        // Skip the header row, then split each line into name and URL. If a name
        // turns up twice the first one wins.
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

    /// Normalises names so small differences in how the coach types them still match,
    /// e.g. "Farmer's Walk" → "farmerswalk" and "Goblet squats" → "gobletsquat".
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

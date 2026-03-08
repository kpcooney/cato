//
//  ExerciseDatabase.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Loads exercise data from exercises.json and provides search/autocomplete.
//  Used by the program builder's activity editor to help users find exercises.
//

import Foundation

/// A single exercise entry from the exercise database.
/// Each exercise has a canonical name, category, equipment type, and optional aliases
/// for fuzzy matching (e.g., "bench press" matches "Barbell Bench Press").
struct Exercise: Codable, Identifiable, Hashable {
    let name: String
    let category: String
    let equipment: String
    let aliases: [String]

    var id: String { name }
}

/// Searchable database of ~200 common exercises loaded from a bundled JSON file.
/// Supports prefix-prioritized search and category filtering for the program builder's
/// exercise autocomplete.
struct ExerciseDatabase {
    private let exercises: [Exercise]

    /// Initialize by loading exercises from the app bundle's exercises.json.
    /// Falls back to an empty array if the file is missing or malformed.
    init(bundle: Bundle = .main) {
        guard let url = bundle.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Exercise].self, from: data) else {
            exercises = []
            return
        }
        exercises = decoded
    }

    /// Initialize with a provided array of exercises (used for testing).
    init(exercises: [Exercise]) {
        self.exercises = exercises
    }

    /// The total number of exercises in the database.
    var count: Int { exercises.count }

    /// Search exercises by name or alias. Case-insensitive matching with priority ranking:
    /// 1. Name starts with query (highest relevance)
    /// 2. Name contains query
    /// 3. Any alias contains query (lowest relevance)
    /// Returns up to `limit` results.
    func search(_ query: String, limit: Int = 10) -> [Exercise] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let lowered = query.lowercased()

        var namePrefix: [Exercise] = []
        var nameContains: [Exercise] = []
        var aliasMatch: [Exercise] = []

        for exercise in exercises {
            let lowName = exercise.name.lowercased()
            if lowName.hasPrefix(lowered) {
                namePrefix.append(exercise)
            } else if lowName.contains(lowered) {
                nameContains.append(exercise)
            } else if exercise.aliases.contains(where: { $0.lowercased().contains(lowered) }) {
                aliasMatch.append(exercise)
            }
        }

        return Array((namePrefix + nameContains + aliasMatch).prefix(limit))
    }

    /// All exercises in a given category (case-insensitive match).
    func exercises(in category: String) -> [Exercise] {
        exercises.filter { $0.category.lowercased() == category.lowercased() }
    }

    /// All unique category names, sorted alphabetically.
    var categories: [String] {
        Array(Set(exercises.map { $0.category })).sorted()
    }
}

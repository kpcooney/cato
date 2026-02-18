//
//  ExerciseDatabase.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

/// A single exercise entry loaded from exercises.json.
///
/// `id` is derived from `name` so the struct is Identifiable and Hashable
/// without a separate UUID — exercise names are unique in the seed database.
/// If user-defined exercises are added in a future phase, this will need a real UUID.
struct Exercise: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let category: String      // e.g. "Chest", "Back", "Legs"
    let equipment: String     // e.g. "Barbell", "Dumbbell", "Bodyweight"
    let tags: [String]        // e.g. ["compound", "push", "horizontal press"]
}

/// Loads and searches the bundled exercise database (exercises.json).
///
/// Used by ProgramBuilderView to power the live autocomplete field when a user
/// types an exercise name. Injected as an @Observable environment object so the
/// same loaded dataset is shared across all builder views without reloading.
///
/// @Observable is used instead of ObservableObject — `exercises` changes on init
/// and SwiftUI should re-render any dependent views automatically.
@Observable
class ExerciseDatabase {

    /// All exercises loaded from the bundle. Empty until `load()` completes on init.
    private(set) var exercises: [Exercise] = []

    init() {
        load()
    }

    /// Decodes exercises.json from the main bundle. Silently no-ops on failure so
    /// the app doesn't crash if the resource is missing — the search field will just
    /// return no results, which is recoverable in the UI.
    private func load() {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Exercise].self, from: data)
        else {
            return
        }
        exercises = decoded
    }

    /// Returns exercises matching the query across name, category, and tags.
    ///
    /// Prefix matches on name are ranked first so "Bench" returns "Bench Press"
    /// before "Dumbbell Bench Press". Empty query returns all exercises sorted by name
    /// (useful for initial state: show everything before the user types).
    func search(_ query: String) -> [Exercise] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return exercises.sorted { $0.name < $1.name }
        }
        let lower = trimmed.lowercased()
        return exercises.filter {
            $0.name.lowercased().contains(lower) ||
            $0.category.lowercased().contains(lower) ||
            $0.tags.contains(where: { $0.lowercased().contains(lower) })
        }
        .sorted { lhs, rhs in
            // Exact name prefix match scores higher than a mid-string match.
            let lhsPrefix = lhs.name.lowercased().hasPrefix(lower)
            let rhsPrefix = rhs.name.lowercased().hasPrefix(lower)
            if lhsPrefix != rhsPrefix { return lhsPrefix }
            return lhs.name < rhs.name
        }
    }

    /// Distinct category names sorted alphabetically. Used to build category filter pickers.
    var categories: [String] {
        Array(Set(exercises.map(\.category))).sorted()
    }

    /// All exercises in a given category, sorted by name.
    func exercises(in category: String) -> [Exercise] {
        exercises.filter { $0.category == category }.sorted { $0.name < $1.name }
    }
}

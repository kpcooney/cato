//
//  ExerciseSearchView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Searchable exercise list presented as a sheet from ActivityEditorView.
//  Uses ExerciseDatabase for priority-ranked search with autocomplete.
//

import SwiftUI

struct ExerciseSearchView: View {
    /// Callback when the user selects an exercise name.
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    /// Shared exercise database loaded from bundle JSON.
    private let database = ExerciseDatabase()

    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    // Show exercises grouped by category when no search
                    ForEach(database.categories, id: \.self) { category in
                        Section(category.capitalized) {
                            ForEach(database.exercises(in: category)) { exercise in
                                exerciseRow(exercise)
                            }
                        }
                    }
                } else {
                    // Show search results ranked by relevance
                    ForEach(database.search(searchText, limit: 20)) { exercise in
                        exerciseRow(exercise)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            onSelect(exercise.name)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .foregroundStyle(.primary)
                Text("\(exercise.category.capitalized) \u{2022} \(exercise.equipment.capitalized)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel("\(exercise.name), \(exercise.category), \(exercise.equipment)")
    }
}

//
//  DayEditorView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Editor for a single day within a program week. Allows setting the day
//  name, type (training/rest/active recovery), and managing the activity
//  list for training days. Activities can be reordered, added, and deleted.
//

import SwiftUI

struct DayEditorView: View {
    @Binding var day: DraftDay

    var body: some View {
        Form {
            dayInfoSection
            if day.dayType == .training {
                activitiesSection
            }
        }
        .navigationTitle("\(day.dayOfWeek.displayName)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var dayInfoSection: some View {
        Section("Day Info") {
            TextField("Day Name (e.g., Push Day)", text: $day.name)
                .accessibilityLabel("Day name")

            Picker("Type", selection: $day.dayType) {
                ForEach([DayType.training, .rest, .activeRecovery], id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .accessibilityLabel("Day type")

            TextField("Notes", text: $day.notes, axis: .vertical)
                .lineLimit(3)
                .accessibilityLabel("Day notes")
        }
    }

    private var activitiesSection: some View {
        Section {
            if day.activities.isEmpty {
                Text("No exercises yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach($day.activities) { $activity in
                    NavigationLink {
                        ActivityEditorView(activity: $activity)
                    } label: {
                        activityRowLabel(activity)
                    }
                }
                .onMove(perform: moveActivities)
                .onDelete(perform: deleteActivities)
            }

            Button {
                addActivity()
            } label: {
                Label("Add Exercise", systemImage: "plus.circle")
            }
            .accessibilityLabel("Add exercise to this day")
        } header: {
            HStack {
                Text("Exercises")
                Spacer()
                if !day.activities.isEmpty {
                    EditButton()
                        .font(.caption)
                }
            }
        }
    }

    // MARK: - Activity Row

    /// Compact summary shown in the activity list before tapping to edit.
    private func activityRowLabel(_ activity: DraftActivity) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(activity.activityName.isEmpty ? "Untitled Exercise" : activity.activityName)
                .font(.body)
                .foregroundStyle(activity.activityName.isEmpty ? .secondary : .primary)

            HStack(spacing: 8) {
                Text("\(activity.sets) x \(activity.reps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if activity.weight > 0 {
                    Text("\(activity.weight, specifier: "%g") \(activity.weightUnit.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    private func addActivity() {
        var activity = DraftActivity()
        activity.orderIndex = day.activities.count
        day.activities.append(activity)
    }

    private func moveActivities(from source: IndexSet, to destination: Int) {
        day.activities.move(fromOffsets: source, toOffset: destination)
        // Update order indices to match new positions
        for (index, _) in day.activities.enumerated() {
            day.activities[index].orderIndex = index
        }
    }

    private func deleteActivities(at offsets: IndexSet) {
        day.activities.remove(atOffsets: offsets)
        // Reindex remaining activities
        for (index, _) in day.activities.enumerated() {
            day.activities[index].orderIndex = index
        }
    }
}

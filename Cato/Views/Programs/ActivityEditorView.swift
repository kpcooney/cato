//
//  ActivityEditorView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Form for editing a single activity's properties: exercise name (with
//  autocomplete search), sets, reps, weight, and rest between sets.
//  Receives a Binding<DraftActivity> from DayEditorView.
//

import SwiftUI

struct ActivityEditorView: View {
    @Binding var activity: DraftActivity
    @State private var showingExerciseSearch = false

    var body: some View {
        Form {
            exerciseSection
            setsAndRepsSection
            weightSection
            restSection
            notesSection
        }
        .navigationTitle(activity.activityName.isEmpty ? "New Exercise" : activity.activityName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExerciseSearch) {
            ExerciseSearchView { selectedName in
                activity.activityName = selectedName
            }
        }
    }

    // MARK: - Sections

    private var exerciseSection: some View {
        Section("Exercise") {
            Button {
                showingExerciseSearch = true
            } label: {
                HStack {
                    Text(activity.activityName.isEmpty ? "Select Exercise" : activity.activityName)
                        .foregroundStyle(activity.activityName.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel(activity.activityName.isEmpty ? "Select exercise" : activity.activityName)
            .accessibilityHint("Opens exercise search")
        }
    }

    private var setsAndRepsSection: some View {
        Section("Sets & Reps") {
            Stepper("Sets: \(activity.sets)", value: $activity.sets, in: 1...20)
                .accessibilityLabel("Sets")
                .accessibilityValue("\(activity.sets)")
            Stepper("Reps: \(activity.reps)", value: $activity.reps, in: 1...100)
                .accessibilityLabel("Reps")
                .accessibilityValue("\(activity.reps)")
        }
    }

    private var weightSection: some View {
        Section {
            HStack {
                TextField("Weight", value: $activity.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Weight")

                Picker("Unit", selection: $activity.weightUnit) {
                    Text("lbs").tag(TargetUnit.lbs)
                    Text("kg").tag(TargetUnit.kg)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Weight unit")
            }
        } header: {
            Text("Weight")
        } footer: {
            Text("Leave at 0 for bodyweight exercises.")
        }
    }

    private var restSection: some View {
        Section("Rest Between Sets") {
            Picker("Rest", selection: $activity.restBetweenSets) {
                Text("30s").tag(TimeInterval(30))
                Text("60s").tag(TimeInterval(60))
                Text("90s").tag(TimeInterval(90))
                Text("2 min").tag(TimeInterval(120))
                Text("3 min").tag(TimeInterval(180))
                Text("5 min").tag(TimeInterval(300))
            }
            .accessibilityLabel("Rest between sets")
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Optional notes", text: $activity.notes, axis: .vertical)
                .lineLimit(3)
                .accessibilityLabel("Activity notes")
        }
    }
}

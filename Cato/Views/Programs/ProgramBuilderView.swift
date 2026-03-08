//
//  ProgramBuilderView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Manual program creation form with navigation-based drill-down into
//  weeks, days, and activities. Supports both create and edit modes.
//  Operates on a DraftProgram — only converts to @Model objects on save.
//

import SwiftUI

struct ProgramBuilderView: View {
    @State var draft: DraftProgram
    let mode: BuilderMode
    let viewModel: ProgramViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            programInfoSection
            weekSections
            addWeekButton
        }
        .navigationTitle(mode.isCreate ? "New Program" : "Edit Program")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { save() }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
            }
        }
    }

    // MARK: - Program Info

    private var programInfoSection: some View {
        Section("Program Info") {
            TextField("Program Name", text: $draft.name)
                .accessibilityLabel("Program name")

            Picker("Type", selection: $draft.programType) {
                ForEach([ProgramType.strength, .cardio, .hybrid, .flexibility, .custom], id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .accessibilityLabel("Program type")

            TextField("Description (optional)", text: $draft.programDescription, axis: .vertical)
                .lineLimit(3)
                .accessibilityLabel("Program description")
        }
    }

    // MARK: - Week Sections

    @ViewBuilder
    private var weekSections: some View {
        ForEach($draft.weeks) { $week in
            Section {
                Toggle("Deload Week", isOn: $week.isDeloadWeek)
                    .accessibilityLabel("Deload week toggle")

                ForEach($week.days) { $day in
                    NavigationLink {
                        DayEditorView(day: $day)
                    } label: {
                        dayRowLabel(day)
                    }
                }
            } header: {
                HStack {
                    Text("Week \(week.weekNumber)")
                    Spacer()
                    if draft.weeks.count > 1 {
                        Button("Remove") {
                            removeWeek(week)
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                }
            }
        }
    }

    // MARK: - Day Row Label

    /// Compact summary of a day shown in the week section.
    private func dayRowLabel(_ day: DraftDay) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(day.dayOfWeek.shortName)
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: 36, alignment: .leading)

                    if !day.name.isEmpty {
                        Text(day.name)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                if day.dayType == .training && !day.activities.isEmpty {
                    Text("\(day.activities.count) exercise\(day.activities.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            dayTypeBadge(day.dayType)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(day.dayOfWeek.displayName), \(day.dayType.displayName), \(day.activities.count) exercises")
    }

    /// Small colored badge showing the day type.
    private func dayTypeBadge(_ type: DayType) -> some View {
        Text(type.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(badgeColor(for: type).opacity(0.15))
            .foregroundStyle(badgeColor(for: type))
            .cornerRadius(4)
    }

    private func badgeColor(for type: DayType) -> Color {
        switch type {
        case .training: return .blue
        case .rest: return .gray
        case .activeRecovery: return .green
        }
    }

    // MARK: - Add/Remove Weeks

    private var addWeekButton: some View {
        Section {
            Button {
                let nextNumber = (draft.weeks.map { $0.weekNumber }.max() ?? 0) + 1
                draft.weeks.append(DraftWeek.defaultWeek(number: nextNumber))
            } label: {
                Label("Add Week", systemImage: "plus.circle")
            }
            .accessibilityLabel("Add another week")
        }
    }

    private func removeWeek(_ week: DraftWeek) {
        draft.weeks.removeAll { $0.id == week.id }
        // Renumber remaining weeks
        for (index, _) in draft.weeks.enumerated() {
            draft.weeks[index].weekNumber = index + 1
        }
    }

    // MARK: - Validation & Save

    /// Program must have a name and at least one week.
    private var isValid: Bool {
        !draft.name.trimmingCharacters(in: .whitespaces).isEmpty && !draft.weeks.isEmpty
    }

    private func save() {
        switch mode {
        case .create:
            viewModel.saveProgram(draft)
        case .edit(let existingProgram):
            viewModel.updateProgram(existingProgram, from: draft)
        }
        dismiss()
    }
}

// MARK: - BuilderMode Helpers

extension BuilderMode {
    var isCreate: Bool {
        switch self {
        case .create: return true
        case .edit: return false
        }
    }
}

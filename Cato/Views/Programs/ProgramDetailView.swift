//
//  ProgramDetailView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Read-only detail view for a workout program. Displays program metadata,
//  weeks, days, and activities in a structured list. Edit button opens
//  ProgramBuilderView with a DraftProgram conversion for in-place editing.
//

import SwiftUI

struct ProgramDetailView: View {
    let program: WorkoutProgram
    let viewModel: ProgramViewModel

    @State private var showingEditor = false

    var body: some View {
        List {
            programInfoSection
            ForEach(sortedWeeks, id: \.id) { week in
                weekSection(week)
            }
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditor = true
                }
                .accessibilityLabel("Edit program")
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                ProgramBuilderView(
                    draft: DraftProgram.from(program: program),
                    mode: .edit(program),
                    viewModel: viewModel
                )
            }
        }
    }

    // MARK: - Sorted Data

    private var sortedWeeks: [ProgramWeek] {
        program.weeks.sorted { $0.weekNumber < $1.weekNumber }
    }

    private func sortedDays(for week: ProgramWeek) -> [ProgramDay] {
        week.days.sorted { $0.dayOfWeek.rawValue < $1.dayOfWeek.rawValue }
    }

    private func sortedActivities(for day: ProgramDay) -> [ProgramActivity] {
        day.activities.sorted { $0.orderIndex < $1.orderIndex }
    }

    // MARK: - Program Info

    private var programInfoSection: some View {
        Section("Program Info") {
            LabeledContent("Type", value: program.programType.displayName)

            if let description = program.programDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Source", value: program.sourceType.displayName)

            if program.isActive {
                HStack {
                    Text("Status")
                    Spacer()
                    Text("Active")
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            HStack {
                Text("Weeks")
                Spacer()
                Text("\(program.weeks.count)")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Week Section

    private func weekSection(_ week: ProgramWeek) -> some View {
        Section {
            if week.isDeloadWeek {
                HStack {
                    Image(systemName: "arrow.down.circle")
                        .foregroundStyle(.orange)
                    Text("Deload Week")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
            }

            ForEach(sortedDays(for: week), id: \.id) { day in
                dayRow(day)
            }
        } header: {
            Text("Week \(week.weekNumber)")
        }
    }

    // MARK: - Day Row

    private func dayRow(_ day: ProgramDay) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(day.dayOfWeek.shortName)
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(width: 36, alignment: .leading)

                if let name = day.name, !name.isEmpty {
                    Text(name)
                        .font(.body)
                }

                Spacer()

                dayTypeBadge(day.dayType)
            }

            if day.dayType == .training && !day.activities.isEmpty {
                ForEach(sortedActivities(for: day), id: \.id) { activity in
                    activityRow(activity)
                }
            }

            if let notes = day.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Activity Row

    private func activityRow(_ activity: ProgramActivity) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 4))
                .foregroundStyle(.secondary)
                .padding(.leading, 36)

            Text(activity.activityName)
                .font(.subheadline)

            Spacer()

            Text(activitySummary(activity))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("\(activity.activityName), \(activitySummary(activity))")
    }

    /// Compact summary string for an activity (e.g., "5x5 @ 185 lbs").
    private func activitySummary(_ activity: ProgramActivity) -> String {
        let repsTarget = activity.targets.first { $0.metric == .reps }
        let weightTarget = activity.targets.first { $0.metric == .weight }

        let sets = repsTarget?.repeatCount ?? 0
        let reps = Int(repsTarget?.value ?? 0)

        if let wt = weightTarget, wt.value > 0 {
            let formattedWeight = wt.value.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", wt.value)
                : String(format: "%g", wt.value)
            return "\(sets)x\(reps) @ \(formattedWeight) \(wt.unit.rawValue)"
        } else {
            return "\(sets)x\(reps)"
        }
    }

    // MARK: - Day Type Badge

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
}

// MARK: - SourceType Display Name

extension SourceType {
    var displayName: String {
        switch self {
        case .manual: return "Manual"
        case .naturalLanguage: return "AI Builder"
        case .url: return "URL Import"
        }
    }
}

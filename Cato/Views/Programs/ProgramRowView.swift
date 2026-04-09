//
//  ProgramRowView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Row component displayed in ProgramListView. Shows program name, type,
//  description, active badge, and contextual metadata.
//

import SwiftUI

struct ProgramRowView: View {
    let program: WorkoutProgram

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(program.name)
                    .font(.headline)

                Spacer()

                if program.isActive {
                    Text("Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .accessibilityLabel("Active program")
                }
            }

            if let description = program.programDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Text(program.programType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Show week and training day counts for context
                if !program.weeks.isEmpty {
                    let weekCount = program.weeks.count
                    let trainingDays = program.weeks.first?.days
                        .filter { $0.dayType == .training }.count ?? 0
                    Text("\(weekCount)w \(trainingDays)d/wk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = [program.name, program.programType.displayName]
        if program.isActive { parts.append("Active") }
        if let desc = program.programDescription { parts.append(desc) }
        return parts.joined(separator: ", ")
    }
}

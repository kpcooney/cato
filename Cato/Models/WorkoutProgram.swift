//
//  WorkoutProgram.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// The top-level container for a training program.
///
/// A WorkoutProgram owns a set of weeks (which own days, which own activities).
/// Only one program may be active at a time — enforced by ProgramViewModel.setActive().
/// Deleting a program cascades through all child records automatically.
@Model
class WorkoutProgram {
    var id: UUID
    var name: String
    var programDescription: String?

    /// Drives UI labeling and default rest-time decisions.
    var programType: ProgramType

    /// How the program was created — shown as a badge in ProgramDetailView.
    var sourceType: SourceType

    /// The original free-text or URL the user provided (for NL-parsed programs).
    /// Kept so the user can re-parse if the models improve.
    var sourceText: String?

    var createdAt: Date
    var updatedAt: Date

    /// Whether this is the program loaded when the user taps "Start Workout".
    /// Only one program should have isActive == true at any time.
    var isActive: Bool

    /// Cascade delete: removing the program removes all its weeks, days, and activities.
    @Relationship(deleteRule: .cascade)
    var weeks: [ProgramWeek]

    /// Program-level progression defaults. Individual activities can override via
    /// ProgramActivity.progressionRuleOverride. Cascade delete keeps orphan rules from accumulating.
    @Relationship(deleteRule: .cascade)
    var defaultProgressionRules: [ProgressionRule]

    init(
        id: UUID = UUID(),
        name: String,
        programDescription: String? = nil,
        programType: ProgramType,
        sourceType: SourceType,
        sourceText: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = false,
        weeks: [ProgramWeek] = [],
        defaultProgressionRules: [ProgressionRule] = []
    ) {
        self.id = id
        self.name = name
        self.programDescription = programDescription
        self.programType = programType
        self.sourceType = sourceType
        self.sourceText = sourceText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.weeks = weeks
        self.defaultProgressionRules = defaultProgressionRules
    }
}

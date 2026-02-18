//
//  ProgramActivity.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// A single prescribed exercise or movement within a training day.
///
/// ProgramActivity is the core abstraction of the schema — it is modality-agnostic.
/// What "done" means is defined by the activity's ActivityTargets, not by the activity itself.
/// This lets the same model represent a barbell squat (sets × reps × weight),
/// a timed plank (3 × 60s), or a tempo run (5 miles at 8:30/mile) without schema changes.
@Model
class ProgramActivity {
    var id: UUID

    /// Display name sourced from ExerciseDatabase or free-typed by the user.
    var activityName: String

    /// Movement modality — used as a hint by the session UI to decide which
    /// input controls to show (e.g. rep buttons for strength vs. timer for timed).
    var activityType: ActivityType

    /// Zero-based position within the day's activity list. The session UI
    /// advances through activities in ascending orderIndex order.
    var orderIndex: Int

    /// Seconds to rest between sets for this activity. Nil means no rest timer shown.
    /// Default is 60s; compound movements (detected via ExerciseDatabase tags) default to 90s.
    var restBetweenSets: TimeInterval?

    /// Seconds to rest after all sets of this activity are complete before
    /// moving to the next activity. Typically nil for strength programs.
    var restAfterActivity: TimeInterval?

    var notes: String?

    /// One or more targets that define what "completing" this activity means.
    /// For strength: a reps target and a weight target. See ActivityTarget for examples.
    /// Cascade delete keeps orphaned targets from accumulating.
    @Relationship(deleteRule: .cascade)
    var targets: [ActivityTarget]

    /// If set, overrides the program's defaultProgressionRules for this activity only.
    /// Useful when one exercise in a program progresses differently than the rest.
    var progressionRuleOverride: ProgressionRule?

    /// Back-reference to the parent day.
    var day: ProgramDay?

    init(
        id: UUID = UUID(),
        activityName: String,
        activityType: ActivityType,
        orderIndex: Int,
        restBetweenSets: TimeInterval? = nil,
        restAfterActivity: TimeInterval? = nil,
        notes: String? = nil,
        targets: [ActivityTarget] = [],
        progressionRuleOverride: ProgressionRule? = nil,
        day: ProgramDay? = nil
    ) {
        self.id = id
        self.activityName = activityName
        self.activityType = activityType
        self.orderIndex = orderIndex
        self.restBetweenSets = restBetweenSets
        self.restAfterActivity = restAfterActivity
        self.notes = notes
        self.targets = targets
        self.progressionRuleOverride = progressionRuleOverride
        self.day = day
    }
}

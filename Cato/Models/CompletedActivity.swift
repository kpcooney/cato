//
//  CompletedActivity.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// Records the user's performance on one exercise during a session.
///
/// activityName is denormalized (copied from ProgramActivity.activityName) so that
/// history remains readable even if the original program is edited or deleted later.
///
/// Set-based activities (strength) use the `sets` relationship.
/// Continuous activities (future cardio/timed) use `completedTargets`.
@Model
class CompletedActivity {
    var id: UUID

    /// Denormalized exercise name — preserves history if the program is later modified.
    var activityName: String

    var activityType: ActivityType

    /// true if the user tapped "Skip Exercise" rather than completing any sets.
    var skipped: Bool

    var notes: String?

    /// Soft reference to the program template this was based on. nil-safe so
    /// history isn't broken if the source activity is deleted.
    var programActivity: ProgramActivity?

    var session: WorkoutSession?

    /// Individual sets logged during the session (for strength activities).
    /// Cascade delete keeps orphaned set records from accumulating.
    @Relationship(deleteRule: .cascade)
    var sets: [CompletedSet]

    /// For future continuous activities (cardio, timed holds) that don't use sets.
    @Relationship(deleteRule: .cascade)
    var completedTargets: [CompletedTarget]

    init(
        id: UUID = UUID(),
        activityName: String,
        activityType: ActivityType,
        skipped: Bool = false,
        notes: String? = nil,
        programActivity: ProgramActivity? = nil,
        session: WorkoutSession? = nil,
        sets: [CompletedSet] = [],
        completedTargets: [CompletedTarget] = []
    ) {
        self.id = id
        self.activityName = activityName
        self.activityType = activityType
        self.skipped = skipped
        self.notes = notes
        self.programActivity = programActivity
        self.session = session
        self.sets = sets
        self.completedTargets = completedTargets
    }
}

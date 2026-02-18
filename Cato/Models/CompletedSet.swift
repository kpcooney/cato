//
//  CompletedSet.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// Records one set of a strength activity during a session.
///
/// Both the prescribed targets and the actual performance are stored so that
/// history views can show target-vs-actual comparisons, and the ProgressionService
/// can determine whether all reps were hit.
@Model
class CompletedSet {
    var id: UUID

    /// 1-based set number within the activity (Set 1, Set 2, etc.).
    var setNumber: Int

    /// What was prescribed for this set.
    var targetReps: Int
    var targetWeight: Double

    /// What the user actually did. actualWeight may differ from targetWeight
    /// if the user overrode the weight mid-session.
    var completedReps: Int
    var actualWeight: Double

    /// Unit for both targetWeight and actualWeight (always consistent within a set).
    var weightUnit: TargetUnit

    /// True when completedReps < targetReps. Computed at log time by SessionViewModel,
    /// stored here so ProgressionService doesn't have to recompute it.
    var isFailure: Bool

    /// Rate of Perceived Exertion (1–10 scale). Optional — users may enable this
    /// in Settings. Used by ProgressionRules with conditionType == .rpeBelow.
    var rpe: Double?

    /// When the set was logged. Used for per-set duration analysis (future).
    var timestamp: Date

    var completedActivity: CompletedActivity?

    init(
        id: UUID = UUID(),
        setNumber: Int,
        targetReps: Int,
        completedReps: Int,
        targetWeight: Double,
        actualWeight: Double,
        weightUnit: TargetUnit,
        isFailure: Bool,
        rpe: Double? = nil,
        timestamp: Date = Date(),
        completedActivity: CompletedActivity? = nil
    ) {
        self.id = id
        self.setNumber = setNumber
        self.targetReps = targetReps
        self.completedReps = completedReps
        self.targetWeight = targetWeight
        self.actualWeight = actualWeight
        self.weightUnit = weightUnit
        self.isFailure = isFailure
        self.rpe = rpe
        self.timestamp = timestamp
        self.completedActivity = completedActivity
    }
}

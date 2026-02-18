//
//  ProgressionEvent.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// An immutable audit log entry recording a single progression decision.
///
/// Created by ProgressionService after each session evaluation. Events are never
/// modified after creation — they form a permanent history of how Cato adjusted
/// targets over time. This lets the user see the exact reasoning behind every
/// weight increase or deload, visible in SessionDetailView and per-activity history.
@Model
class ProgressionEvent {
    var id: UUID

    /// Denormalized exercise name — preserved even if the source program is deleted.
    var activityName: String

    var date: Date

    /// Which metric was adjusted (usually .weight or .reps).
    var metric: TargetMetric

    /// The value before progression was applied.
    var previousValue: Double

    /// The value after progression was applied.
    var newValue: Double

    var unit: TargetUnit

    /// Human-readable explanation of why progression fired (or why a deload was triggered).
    /// Examples: "All reps completed 3 sessions in a row", "Deload: 3 consecutive failures"
    /// Surfaced in the session summary and history views.
    var reason: String

    /// The session during which this progression was evaluated.
    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        activityName: String,
        date: Date = Date(),
        metric: TargetMetric,
        previousValue: Double,
        newValue: Double,
        unit: TargetUnit,
        reason: String,
        session: WorkoutSession? = nil
    ) {
        self.id = id
        self.activityName = activityName
        self.date = date
        self.metric = metric
        self.previousValue = previousValue
        self.newValue = newValue
        self.unit = unit
        self.reason = reason
        self.session = session
    }
}

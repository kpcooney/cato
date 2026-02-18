//
//  CompletedTarget.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// Records the actual vs. target value for one metric in a continuous activity.
///
/// Currently unused (Phase 1–2 focus is strength / set-based activities).
/// Reserved for future cardio, timed, and distance activities where "sets"
/// don't apply — e.g. a 5-mile run where target was 8:30/mile and actual was 8:45/mile.
@Model
class CompletedTarget {
    var id: UUID
    var metric: TargetMetric
    var targetValue: Double
    var actualValue: Double
    var unit: TargetUnit
    var timestamp: Date

    var completedActivity: CompletedActivity?

    init(
        id: UUID = UUID(),
        metric: TargetMetric,
        targetValue: Double,
        actualValue: Double,
        unit: TargetUnit,
        timestamp: Date = Date(),
        completedActivity: CompletedActivity? = nil
    ) {
        self.id = id
        self.metric = metric
        self.targetValue = targetValue
        self.actualValue = actualValue
        self.unit = unit
        self.timestamp = timestamp
        self.completedActivity = completedActivity
    }
}

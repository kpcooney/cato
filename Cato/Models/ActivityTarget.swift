//
//  ActivityTarget.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// A single measurable target within a ProgramActivity.
///
/// The flexible metric/value/unit/repeatCount design is what makes the schema
/// modality-agnostic. Rather than having separate fields for sets, reps, and weight,
/// each aspect of "what to do" is its own target record.
///
/// Examples:
///   Bench Press 5×5 @ 185 lbs → two targets:
///     ActivityTarget(metric: .reps,   value: 5,   unit: .count, repeatCount: 5)
///     ActivityTarget(metric: .weight, value: 185, unit: .lbs,   repeatCount: nil)
///
///   3×60s plank (future):
///     ActivityTarget(metric: .duration, value: 60, unit: .seconds, repeatCount: 3)
///
///   5-mile tempo run at 8:30/mile (future):
///     ActivityTarget(metric: .distance, value: 5,   unit: .miles,      repeatCount: nil)
///     ActivityTarget(metric: .pace,     value: 8.5, unit: .minPerMile, repeatCount: nil)
@Model
class ActivityTarget {
    var id: UUID

    /// What is being measured (reps, weight, distance, duration, pace, etc.).
    var metric: TargetMetric

    /// The prescribed value (e.g. 5 for reps, 185 for weight, 60 for seconds).
    var value: Double

    /// The unit for the value (e.g. .count for reps, .lbs or .kg for weight).
    var unit: TargetUnit

    /// How many times to repeat this target (sets for strength, intervals for cardio).
    /// nil means the target applies once (e.g. a single weight prescription).
    var repeatCount: Int?

    /// Back-reference to the parent activity.
    var activity: ProgramActivity?

    init(
        id: UUID = UUID(),
        metric: TargetMetric,
        value: Double,
        unit: TargetUnit,
        repeatCount: Int? = nil,
        activity: ProgramActivity? = nil
    ) {
        self.id = id
        self.metric = metric
        self.value = value
        self.unit = unit
        self.repeatCount = repeatCount
        self.activity = activity
    }
}

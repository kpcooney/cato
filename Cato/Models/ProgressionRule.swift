//
//  ProgressionRule.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// Defines how and when Cato advances the target value for an activity.
///
/// Rules are evaluated by ProgressionService after each completed session.
/// A rule may be attached to a program (applies to all activities as a default)
/// or to a specific activity (overrides the program default for that exercise only).
///
/// If neither applies, no automatic progression occurs.
@Model
class ProgressionRule {
    var id: UUID

    /// Which target metric this rule adjusts (usually .weight or .reps).
    var targetMetric: TargetMetric

    /// The progression algorithm to apply when the condition is met.
    var type: ProgressionType

    /// The magnitude of the progression. Interpretation depends on type:
    ///   .percentage:     10.0 means add 10% (multiply by 1.10)
    ///   .fixedIncrement: 5.0 means add 5 lbs/kg/reps
    ///   .repIncrease:    1.0 means add 1 rep per set
    var value: Double
    var unit: ProgressionUnit

    /// The performance condition that must be satisfied to trigger progression.
    var conditionType: ConditionType

    /// Used when conditionType == .rpeBelow. Progression fires if average RPE < this value.
    var conditionThreshold: Double?

    /// How many sessions in a row must satisfy the condition before progression fires.
    /// Set to 1 for immediate progression (e.g. linear progression programs like 5×5).
    var consecutiveSuccesses: Int

    /// How frequently the rule is evaluated (per session, per week, per cycle).
    var frequency: ProgressionFrequency

    /// After this many consecutive failed sessions, trigger a deload instead of progressing.
    /// nil means no automatic deload is applied.
    var failuresBeforeDeload: Int?

    /// Percentage to reduce the target by when a deload is triggered.
    /// e.g. 10.0 reduces weight by 10%.
    var deloadPercentage: Double?

    /// How many sessions to hold at the deloaded weight before resuming normal progression.
    var deloadDuration: Int?

    /// Program this rule belongs to (when used as a program-level default).
    var program: WorkoutProgram?

    /// Activity this rule belongs to (when used as a per-exercise override).
    var activity: ProgramActivity?

    init(
        id: UUID = UUID(),
        targetMetric: TargetMetric,
        type: ProgressionType,
        value: Double,
        unit: ProgressionUnit,
        conditionType: ConditionType,
        conditionThreshold: Double? = nil,
        consecutiveSuccesses: Int,
        frequency: ProgressionFrequency,
        failuresBeforeDeload: Int? = nil,
        deloadPercentage: Double? = nil,
        deloadDuration: Int? = nil,
        program: WorkoutProgram? = nil,
        activity: ProgramActivity? = nil
    ) {
        self.id = id
        self.targetMetric = targetMetric
        self.type = type
        self.value = value
        self.unit = unit
        self.conditionType = conditionType
        self.conditionThreshold = conditionThreshold
        self.consecutiveSuccesses = consecutiveSuccesses
        self.frequency = frequency
        self.failuresBeforeDeload = failuresBeforeDeload
        self.deloadPercentage = deloadPercentage
        self.deloadDuration = deloadDuration
        self.program = program
        self.activity = activity
    }
}

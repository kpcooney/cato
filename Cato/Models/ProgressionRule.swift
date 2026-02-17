//
//  ProgressionRule.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ProgressionRule {
    var id: UUID
    var targetMetric: TargetMetric
    var type: ProgressionType
    var value: Double
    var unit: ProgressionUnit
    var conditionType: ConditionType
    var conditionThreshold: Double?
    var consecutiveSuccesses: Int
    var frequency: ProgressionFrequency
    var failuresBeforeDeload: Int?
    var deloadPercentage: Double?
    var deloadDuration: Int?

    var program: WorkoutProgram?
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

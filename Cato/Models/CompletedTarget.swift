//
//  CompletedTarget.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

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

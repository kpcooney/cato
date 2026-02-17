//
//  ProgressionEvent.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ProgressionEvent {
    var id: UUID
    var activityName: String
    var date: Date
    var metric: TargetMetric
    var previousValue: Double
    var newValue: Double
    var unit: TargetUnit
    var reason: String

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

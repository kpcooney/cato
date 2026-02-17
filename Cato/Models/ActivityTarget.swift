//
//  ActivityTarget.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ActivityTarget {
    var id: UUID
    var metric: TargetMetric
    var value: Double
    var unit: TargetUnit
    var repeatCount: Int?

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

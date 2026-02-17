//
//  CompletedSet.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class CompletedSet {
    var id: UUID
    var setNumber: Int
    var targetReps: Int
    var completedReps: Int
    var targetWeight: Double
    var actualWeight: Double
    var weightUnit: TargetUnit
    var isFailure: Bool
    var rpe: Double?
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

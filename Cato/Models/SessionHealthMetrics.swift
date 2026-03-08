//
//  SessionHealthMetrics.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class SessionHealthMetrics {
    var id: UUID
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var minHeartRate: Double?
    var activeCalories: Double?
    var totalCalories: Double?
    var duration: TimeInterval

    var heartRateSampleTimestamps: [Date]
    var heartRateSampleValues: [Double]

    var session: WorkoutSession?

    init(
        id: UUID = UUID(),
        averageHeartRate: Double? = nil,
        maxHeartRate: Double? = nil,
        minHeartRate: Double? = nil,
        activeCalories: Double? = nil,
        totalCalories: Double? = nil,
        duration: TimeInterval,
        heartRateSampleTimestamps: [Date] = [],
        heartRateSampleValues: [Double] = [],
        session: WorkoutSession? = nil
    ) {
        self.id = id
        self.averageHeartRate = averageHeartRate
        self.maxHeartRate = maxHeartRate
        self.minHeartRate = minHeartRate
        self.activeCalories = activeCalories
        self.totalCalories = totalCalories
        self.duration = duration
        self.heartRateSampleTimestamps = heartRateSampleTimestamps
        self.heartRateSampleValues = heartRateSampleValues
        self.session = session
    }
}

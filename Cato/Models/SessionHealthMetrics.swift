//
//  SessionHealthMetrics.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// Heart rate and calorie data collected from Apple Watch during a session.
///
/// This record is only created when HealthKit authorization has been granted and
/// an Apple Watch is connected. When nil on WorkoutSession.healthMetrics, the history
/// UI gracefully omits health data without showing errors.
///
/// Heart rate samples are stored as two parallel arrays (timestamps + values) rather
/// than a separate model class because SwiftData doesn't support array-of-struct
/// properties directly, and a separate HRSample model would add unnecessary overhead
/// for what are effectively time-series data points.
@Model
class SessionHealthMetrics {
    var id: UUID
    var averageHeartRate: Double?
    var maxHeartRate: Double?
    var minHeartRate: Double?

    /// Calories from movement only (excludes basal metabolic rate).
    var activeCalories: Double?

    /// Active + resting calories for the session duration.
    var totalCalories: Double?

    /// Total session duration in seconds (endTime - startTime), duplicated here
    /// for convenience so health queries don't need to join the parent session.
    var duration: TimeInterval

    /// Parallel arrays: heartRateSampleTimestamps[i] corresponds to heartRateSampleValues[i].
    /// Populated by HealthKitService.observeHeartRate() during the session.
    var heartRateSampleTimestamps: [Date]
    var heartRateSampleValues: [Double]  // bpm

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

//
//  HealthKitService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import HealthKit

protocol HealthKitServiceProtocol {
    func requestAuthorization() async throws
    func startWorkoutSession() async throws
    func endWorkoutSession() async throws -> SessionHealthMetrics?
    func observeHeartRate(onSample: @escaping (Double, Date) -> Void)
}

/// Interfaces with HealthKit to capture heart rate and calorie data during sessions.
///
/// All HealthKit access is read-only in v1. Cato does not write workouts back to
/// Apple Health (reserved for a future phase). If HealthKit is unavailable (simulator,
/// iPad without Watch) or authorization is denied, all methods fail gracefully —
/// sessions are unaffected and healthMetrics stays nil on WorkoutSession.
///
/// Implementation is stubbed for Phase 1–2. Full implementation lands in Phase 5.
class HealthKitService: HealthKitServiceProtocol {

    private let healthStore = HKHealthStore()

    /// Active workout session reference. Non-nil only when a session is in progress
    /// and an Apple Watch is connected. Used to properly end the HK session on completion.
    private var workoutSession: HKWorkoutSession?

    /// Requests read authorization for the data types Cato uses during sessions.
    /// Must be called before starting any workout session. Safe to call multiple times
    /// — HealthKit shows the permissions sheet only on the first call.
    func requestAuthorization() async throws {
        // HealthKit is not available on all devices (e.g. iPad without Watch connectivity).
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(
                domain: "HealthKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit not available on this device"]
            )
        }

        // Read-only access: heart rate, active calories, basal calories, and workout metadata.
        // We pass an empty set for `toShare` because v1 does not write to HealthKit.
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.workoutType()
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }

    /// Starts an HKWorkoutSession on the paired Apple Watch (Phase 5).
    /// No-op if no Watch is connected — session continues without health tracking.
    func startWorkoutSession() async throws {
        // TODO (Phase 5): Start HKWorkoutSession for Watch-connected users.
    }

    /// Ends the HKWorkoutSession and aggregates HR and calorie metrics (Phase 5).
    /// Returns nil when no Watch session was active.
    func endWorkoutSession() async throws -> SessionHealthMetrics? {
        // TODO (Phase 5): Aggregate avg/max/min HR and active + total calories.
        return nil
    }

    /// Subscribes to live heart rate samples via HKAnchoredObjectQuery (Phase 5).
    /// The callback is invoked on a background thread for each new HR sample.
    func observeHeartRate(onSample: @escaping (Double, Date) -> Void) {
        // TODO (Phase 5): Set up HKAnchoredObjectQuery with long-running observer.
    }
}

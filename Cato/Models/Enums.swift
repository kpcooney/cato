//
//  Enums.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

// MARK: - Program-level enums

/// The overall training style of a program. Drives default rest times and
/// how the UI labels progression (e.g. weight for strength, pace for cardio).
enum ProgramType: String, Codable {
    case strength
    case cardio
    case hybrid
    case flexibility
    case custom
}

/// Records how the program was created. Displayed as a badge in ProgramDetailView
/// and used to decide whether to show a "re-parse" option on AI-generated programs.
enum SourceType: String, Codable {
    case manual           // built via ProgramBuilderView form
    case naturalLanguage  // parsed from free text via FoundationModelsService
    case url              // parsed from a fetched web page
}

/// 1-indexed to match ISO 8601 convention (Monday = 1).
/// CaseIterable lets us iterate all days when building the week-grid UI.
enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

/// Whether a day has scheduled work. Rest and activeRecovery days have no
/// ProgramActivities — the session UI shows a rest message instead of exercise list.
enum DayType: String, Codable {
    case training
    case rest
    case activeRecovery
}

// MARK: - Activity-level enums

/// The movement modality of a single activity. Determines which target metrics
/// are meaningful (e.g. strength → reps + weight; distance → miles + pace).
/// The data model is modality-agnostic — this is a hint to the UI and progression engine.
enum ActivityType: String, Codable {
    case strength  // sets × reps × weight (Phase 1 focus)
    case cardio    // continuous effort — future
    case distance  // measured in miles/km — future
    case timed     // held for N seconds (planks, etc.) — future
    case custom
}

/// Which aspect of performance an ActivityTarget measures.
/// A strength exercise uses two targets: reps (.count) and weight (.lbs/.kg).
/// Storing metric + unit on each target avoids hard-coding type assumptions in the model.
enum TargetMetric: String, Codable {
    case reps
    case weight
    case distance
    case duration
    case pace
    case calories
    case heartRateZone
}

/// The unit that accompanies a TargetMetric value.
/// Stored on each ActivityTarget so unit preferences can change per-user
/// without requiring a data migration.
enum TargetUnit: String, Codable {
    case count      // for reps
    case lbs
    case kg
    case miles
    case km
    case meters
    case seconds
    case minutes
    case hours
    case minPerMile
    case minPerKm
    case bpm        // beats per minute, used for heartRateZone targets
}

// MARK: - Progression enums

/// The algorithm ProgressionService uses to calculate the new target value
/// when a progression condition is met. See ProgressionService for implementation.
enum ProgressionType: String, Codable {
    case percentage      // newWeight = currentWeight × (1 + value / 100)
    case fixedIncrement  // newWeight = currentWeight + value
    case repIncrease     // newReps = currentReps + value, with optional ceiling + weight bump
}

/// Unit for the progression increment amount. Separate from TargetUnit because
/// percent is a valid progression unit but not a valid target measurement unit.
enum ProgressionUnit: String, Codable {
    case percent
    case lbs
    case kg
    case reps
    case seconds
    case minutes
    case miles
    case km
}

/// How often a ProgressionRule is evaluated against completed sessions.
/// perSession: applied immediately after each session.
/// perWeek: once per 7-day window, regardless of how many sessions occurred.
/// perCycle: once at the end of a full program week cycle.
enum ProgressionFrequency: String, Codable {
    case perSession
    case perWeek
    case perCycle
}

/// The condition that must be true for a progression event to trigger.
/// allTargetsMet: every prescribed set hit its target reps at target weight.
/// rpeBelow: user-reported effort was under conditionThreshold (e.g. RPE < 8).
/// custom: reserved for future rule types.
enum ConditionType: String, Codable {
    case allTargetsMet
    case rpeBelow
    case custom
}

// MARK: - Session enums

/// Lifecycle state of a WorkoutSession.
/// Sessions left as inProgress after a crash or backgrounding should be treated
/// as abandoned on next launch — not resumed silently.
enum SessionStatus: String, Codable {
    case inProgress
    case completed
    case abandoned
}

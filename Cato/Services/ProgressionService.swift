//
//  ProgressionService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

protocol ProgressionServiceProtocol {
    /// Evaluates whether a progression rule fires after a completed set of activity sets.
    /// Returns a ProgressionEvent describing the change (or deload), or nil if no rule triggered.
    func evaluateProgression(
        for activity: ProgramActivity,
        completedSets: [CompletedSet],
        rule: ProgressionRule
    ) -> ProgressionEvent?
}

/// Runs after each session to decide if targets should increase, hold, or deload.
///
/// The engine is called by SessionViewModel once the user marks a session complete.
/// It operates on a per-activity basis: for each activity that has a ProgressionRule
/// (either a program-level default or an activity-specific override), it checks whether
/// the condition was met and how many consecutive successes or failures have accumulated.
///
/// Three progression types (v1):
///   - .percentage   → multiply current weight by (1 + value/100), round to plate increment
///   - .fixedIncrement → add `value` lbs or kg directly
///   - .repIncrease  → add `value` reps per set; when a rep ceiling is reached, bump weight
///
/// Deload logic: after `failuresBeforeDeload` consecutive failures, reduce the target weight
/// by `deloadPercentage`% and hold there for `deloadDuration` sessions before resuming.
///
/// Every decision (progression or deload) produces a ProgressionEvent that is persisted
/// to SwiftData, surfaced in the session summary, and announced by CatoSpeechService.
///
/// Fully stubbed for Phase 1–2. Full implementation lands in Phase 4.
class ProgressionService: ProgressionServiceProtocol {

    /// Evaluates the given rule against the completed sets and returns a ProgressionEvent
    /// if a progression or deload is triggered, or nil if no change is warranted.
    ///
    /// The caller (SessionViewModel) is responsible for applying the returned event's
    /// `newValue` to the corresponding ActivityTarget and persisting the model context.
    func evaluateProgression(
        for activity: ProgramActivity,
        completedSets: [CompletedSet],
        rule: ProgressionRule
    ) -> ProgressionEvent? {
        // TODO (Phase 4): Evaluate rule.conditionType against completedSets.
        //   1. Count consecutive successes / failures across sessions.
        //   2. Check rule.consecutiveSuccesses threshold.
        //   3. On success: calculate new target using rule.type and WeightRounding.
        //   4. On failure × failuresBeforeDeload: apply deload percentage.
        //   5. Build and return ProgressionEvent with reason string for Cato's announcement.
        return nil
    }
}

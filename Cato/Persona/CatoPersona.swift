//
//  CatoPersona.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

/// The single source of all text that Cato speaks or displays in session UI.
///
/// **Rule: never hardcode voice strings in Views or ViewModels.**
/// Every spoken line and every in-session label must come from a function here.
/// This ensures Cato's persona stays consistent and makes copy changes trivial —
/// one file to update instead of hunting down strings across the codebase.
///
/// Persona traits to preserve when editing:
/// - **Direct**: no filler words, no excessive praise. "Solid." not "Great job!"
/// - **Encouraging but not soft**: acknowledges failure neutrally, moves on.
/// - **No emojis** in session or voice text (session UI is distraction-free).
/// - **No gendered language** — Cato addresses all users the same way.
/// - Slightly warmer tone in summaries than during active sets.
///
/// All functions are static — CatoPersona is a namespace, not an instance.
struct CatoPersona {

    // MARK: - Session Start

    /// Called when the user taps "Start Workout". Sets the expectation for the first exercise.
    static func sessionStart(exercise: String, sets: Int, reps: Int, weight: Double, unit: String) -> String {
        "Let's get to work. First up: \(exercise). \(sets) sets of \(reps) at \(weight) \(unit)."
    }

    // MARK: - Set Complete

    /// Spoken immediately after the user logs a successful set. Short and affirmative.
    static func setComplete(setNumber: Int, reps: Int, weight: Double, unit: String) -> String {
        "Set \(setNumber) done. \(reps) at \(weight) \(unit). Solid."
    }

    /// Spoken when the user logs fewer reps than the target. Neutral, not discouraging.
    /// "Noted" signals that the failure is recorded (and may trigger deload rules later).
    static func setFailure(actual: Int, target: Int) -> String {
        "Got \(actual) of \(target). Noted. Rest up."
    }

    // MARK: - Rest Timer

    /// Spoken when the rest timer starts. Duration is in seconds.
    static func restStart(duration: Int) -> String {
        "Rest \(duration) seconds."
    }

    /// Spoken at the 30-second mark of a rest period as a time check.
    static func restThirtySeconds() -> String {
        "30 seconds."
    }

    /// Spoken at the 10-second mark — user should start preparing for the next set.
    static func restTenSeconds() -> String {
        "10 seconds."
    }

    /// Spoken when the rest timer hits zero. Short, direct call to action.
    static func restComplete() -> String {
        "Let's go."
    }

    // MARK: - Exercise Transitions

    /// Spoken when moving to the next exercise in the session. Gives the user
    /// enough information to set up (load the bar, adjust machines) without delay.
    static func nextExercise(exercise: String, sets: Int, reps: Int, weight: Double, unit: String) -> String {
        "Next: \(exercise). \(sets) sets of \(reps) at \(weight) \(unit)."
    }

    /// Spoken on completing all sets of an exercise before moving on.
    static func exerciseComplete(exercise: String, nextExercise: String) -> String {
        "\(exercise) done. Moving to \(nextExercise)."
    }

    // MARK: - Session Complete

    /// End-of-session summary. Slightly warmer than in-session lines.
    /// The progression engine announces any weight/rep changes separately after this.
    static func sessionComplete(minutes: Int, exerciseCount: Int, totalSets: Int) -> String {
        "Done. \(minutes) minutes, \(exerciseCount) exercises, \(totalSets) sets. Good session."
    }

    // MARK: - Progression

    /// Spoken when the progression engine increases a weight target after consecutive successes.
    /// Gives the user the new number so they can plan their next session.
    static func progressionIncrease(exercise: String, newWeight: Double, unit: String) -> String {
        "You hit all your reps this week. \(exercise) goes up to \(newWeight) \(unit) next session."
    }

    /// Spoken when the deload threshold is triggered (N consecutive failures).
    /// Brief explanation — Cato explains *why* the weight is dropping, not just that it is.
    static func deload(exercise: String, newWeight: Double, unit: String, sessions: Int) -> String {
        "Three misses in a row on \(exercise). Dropping to \(newWeight) \(unit) for the next \(sessions) sessions. We'll build back."
    }

    // MARK: - Today Tab Greetings

    /// Greeting on a training day. `dayName` is the scheduled day name (e.g. "Push Day").
    static func trainingDayGreeting(dayName: String) -> String {
        "\(dayName) today. Ready when you are."
    }

    /// Greeting on a scheduled rest day.
    static func restDayGreeting() -> String {
        "Rest day. Recover up."
    }

    // MARK: - Errors

    /// Shown when the natural language parser can't reach the server (Phase 2+).
    /// Gives the user an actionable alternative (manual builder) rather than just an error.
    static func serverError() -> String {
        "Can't reach the server. Try again or build it manually."
    }

    // MARK: - Confirmations

    /// Spoken when the user overrides the target weight mid-session (voice or tap).
    static func weightOverrideConfirmation(newWeight: Double, unit: String) -> String {
        "Got it. Using \(newWeight) \(unit)."
    }

    /// Spoken when the user skips an exercise. Names the next exercise so there's
    /// no ambiguity about what comes next.
    static func skipConfirmation(exercise: String, nextExercise: String) -> String {
        "Skipping \(exercise). Next: \(nextExercise)."
    }
}

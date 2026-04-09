//
//  CatoPersona.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation

struct CatoPersona {

    // MARK: - Session Start

    static func sessionStart(exercise: String, sets: Int, reps: Int, weight: Double, unit: String) -> String {
        "Let's get to work. First up: \(exercise). \(sets) sets of \(reps) at \(weight) \(unit)."
    }

    // MARK: - Set Complete

    static func setComplete(setNumber: Int, reps: Int, weight: Double, unit: String) -> String {
        "Set \(setNumber) done. \(reps) at \(weight) \(unit). Solid."
    }

    static func setFailure(actual: Int, target: Int) -> String {
        "Got \(actual) of \(target). Noted. Rest up."
    }

    // MARK: - Rest Timer

    static func restStart(duration: Int) -> String {
        "Rest \(duration) seconds."
    }

    static func restThirtySeconds() -> String {
        "30 seconds."
    }

    static func restTenSeconds() -> String {
        "10 seconds."
    }

    static func restComplete() -> String {
        "Let's go."
    }

    // MARK: - Exercise Transitions

    static func nextExercise(exercise: String, sets: Int, reps: Int, weight: Double, unit: String) -> String {
        "Next: \(exercise). \(sets) sets of \(reps) at \(weight) \(unit)."
    }

    static func exerciseComplete(exercise: String, nextExercise: String) -> String {
        "\(exercise) done. Moving to \(nextExercise)."
    }

    // MARK: - Session Complete

    static func sessionComplete(minutes: Int, exerciseCount: Int, totalSets: Int) -> String {
        "Done. \(minutes) minutes, \(exerciseCount) exercises, \(totalSets) sets. Good session."
    }

    // MARK: - Progression

    static func progressionIncrease(exercise: String, newWeight: Double, unit: String) -> String {
        "You hit all your reps this week. \(exercise) goes up to \(newWeight) \(unit) next session."
    }

    static func deload(exercise: String, newWeight: Double, unit: String, sessions: Int) -> String {
        "Three misses in a row on \(exercise). Dropping to \(newWeight) \(unit) for the next \(sessions) sessions. We'll build back."
    }

    // MARK: - Today Tab Greetings

    static func trainingDayGreeting(dayName: String) -> String {
        "\(dayName) today. Ready when you are."
    }

    static func restDayGreeting() -> String {
        "Rest day. Recover up."
    }

    // MARK: - Program Management

    static func programCreated(name: String) -> String {
        "\(name) saved. Set it active when you're ready."
    }

    static func programActivated(name: String) -> String {
        "\(name) is now active. Let's get after it."
    }

    static func noProgramActive() -> String {
        "No program active. Set one up in the Programs tab."
    }

    // MARK: - Errors

    static func serverError() -> String {
        "Can't reach the server. Try again or build it manually."
    }

    static func programParseError() -> String {
        "Couldn't parse that. Try being more specific, or build it manually."
    }

    // MARK: - Confirmations

    static func weightOverrideConfirmation(newWeight: Double, unit: String) -> String {
        "Got it. Using \(newWeight) \(unit)."
    }

    static func skipConfirmation(exercise: String, nextExercise: String) -> String {
        "Skipping \(exercise). Next: \(nextExercise)."
    }
}

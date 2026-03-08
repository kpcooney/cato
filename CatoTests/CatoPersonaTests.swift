//
//  CatoPersonaTests.swift
//  CatoTests
//

import Testing
@testable import Cato

struct CatoPersonaTests {

    // MARK: - Session Start

    @Test func sessionStart_formatsCorrectly() {
        let result = CatoPersona.sessionStart(
            exercise: "Barbell Bench Press",
            sets: 5,
            reps: 5,
            weight: 185.0,
            unit: "lbs"
        )
        #expect(result == "Let's get to work. First up: Barbell Bench Press. 5 sets of 5 at 185.0 lbs.")
    }

    @Test func sessionStart_usesKilograms() {
        let result = CatoPersona.sessionStart(
            exercise: "Squat",
            sets: 3,
            reps: 8,
            weight: 80.0,
            unit: "kg"
        )
        #expect(result.contains("80.0 kg"))
        #expect(result.contains("Squat"))
    }

    // MARK: - Set Complete

    @Test func setComplete_successFormatsCorrectly() {
        let result = CatoPersona.setComplete(setNumber: 3, reps: 5, weight: 185.0, unit: "lbs")
        #expect(result == "Set 3 done. 5 at 185.0 lbs. Solid.")
    }

    @Test func setComplete_firstSet() {
        let result = CatoPersona.setComplete(setNumber: 1, reps: 10, weight: 135.0, unit: "lbs")
        #expect(result.contains("Set 1"))
        #expect(result.contains("10"))
        #expect(result.contains("135.0 lbs"))
    }

    @Test func setFailure_formatsCorrectly() {
        let result = CatoPersona.setFailure(actual: 3, target: 5)
        #expect(result == "Got 3 of 5. Noted. Rest up.")
    }

    @Test func setFailure_oneRepShort() {
        let result = CatoPersona.setFailure(actual: 4, target: 5)
        #expect(result.contains("4 of 5"))
    }

    // MARK: - Rest Timer

    @Test func restStart_formatsCorrectly() {
        let result = CatoPersona.restStart(duration: 90)
        #expect(result == "Rest 90 seconds.")
    }

    @Test func restStart_sixtySeconds() {
        let result = CatoPersona.restStart(duration: 60)
        #expect(result == "Rest 60 seconds.")
    }

    @Test func restThirtySeconds_isCorrect() {
        #expect(CatoPersona.restThirtySeconds() == "30 seconds.")
    }

    @Test func restTenSeconds_isCorrect() {
        #expect(CatoPersona.restTenSeconds() == "10 seconds.")
    }

    @Test func restComplete_isCorrect() {
        #expect(CatoPersona.restComplete() == "Let's go.")
    }

    // MARK: - Exercise Transitions

    @Test func nextExercise_formatsCorrectly() {
        let result = CatoPersona.nextExercise(
            exercise: "Barbell Squat",
            sets: 5,
            reps: 5,
            weight: 225.0,
            unit: "lbs"
        )
        #expect(result == "Next: Barbell Squat. 5 sets of 5 at 225.0 lbs.")
    }

    @Test func exerciseComplete_formatsCorrectly() {
        let result = CatoPersona.exerciseComplete(
            exercise: "Bench Press",
            nextExercise: "Barbell Row"
        )
        #expect(result == "Bench Press done. Moving to Barbell Row.")
    }

    // MARK: - Session Complete

    @Test func sessionComplete_formatsCorrectly() {
        let result = CatoPersona.sessionComplete(
            minutes: 45,
            exerciseCount: 4,
            totalSets: 16
        )
        #expect(result == "Done. 45 minutes, 4 exercises, 16 sets. Good session.")
    }

    @Test func sessionComplete_singleExercise() {
        let result = CatoPersona.sessionComplete(minutes: 20, exerciseCount: 1, totalSets: 3)
        #expect(result.contains("1 exercises"))
        #expect(result.contains("3 sets"))
    }

    // MARK: - Progression

    @Test func progressionIncrease_formatsCorrectly() {
        let result = CatoPersona.progressionIncrease(
            exercise: "Deadlift",
            newWeight: 315.0,
            unit: "lbs"
        )
        #expect(result == "You hit all your reps this week. Deadlift goes up to 315.0 lbs next session.")
    }

    @Test func deload_formatsCorrectly() {
        let result = CatoPersona.deload(
            exercise: "Bench Press",
            newWeight: 165.0,
            unit: "lbs",
            sessions: 3
        )
        #expect(result == "Three misses in a row on Bench Press. Dropping to 165.0 lbs for the next 3 sessions. We'll build back.")
    }

    @Test func deload_twoSessions() {
        let result = CatoPersona.deload(
            exercise: "Squat",
            newWeight: 200.0,
            unit: "lbs",
            sessions: 2
        )
        #expect(result.contains("2 sessions"))
    }

    // MARK: - Today Tab

    @Test func trainingDayGreeting_includesDayName() {
        let result = CatoPersona.trainingDayGreeting(dayName: "Push Day")
        #expect(result == "Push Day today. Ready when you are.")
    }

    @Test func trainingDayGreeting_pullDay() {
        let result = CatoPersona.trainingDayGreeting(dayName: "Pull Day")
        #expect(result.contains("Pull Day"))
    }

    @Test func restDayGreeting_isCorrect() {
        #expect(CatoPersona.restDayGreeting() == "Rest day. Recover up.")
    }

    // MARK: - Errors

    @Test func serverError_isCorrect() {
        #expect(CatoPersona.serverError() == "Can't reach the server. Try again or build it manually.")
    }

    // MARK: - Confirmations

    @Test func weightOverrideConfirmation_formatsCorrectly() {
        let result = CatoPersona.weightOverrideConfirmation(newWeight: 195.0, unit: "lbs")
        #expect(result == "Got it. Using 195.0 lbs.")
    }

    @Test func skipConfirmation_formatsCorrectly() {
        let result = CatoPersona.skipConfirmation(
            exercise: "Bench Press",
            nextExercise: "Overhead Press"
        )
        #expect(result == "Skipping Bench Press. Next: Overhead Press.")
    }

    // MARK: - Program Management

    @Test func programCreated_formatsCorrectly() {
        let result = CatoPersona.programCreated(name: "Starting Strength")
        #expect(result == "Starting Strength saved. Set it active when you're ready.")
    }

    @Test func programActivated_formatsCorrectly() {
        let result = CatoPersona.programActivated(name: "5x5 Program")
        #expect(result == "5x5 Program is now active. Let's get after it.")
    }

    @Test func noProgramActive_isCorrect() {
        #expect(CatoPersona.noProgramActive() == "No program active. Set one up in the Programs tab.")
    }

    @Test func programParseError_isCorrect() {
        #expect(CatoPersona.programParseError() == "Couldn't parse that. Try being more specific, or build it manually.")
    }

    // MARK: - Persona Rules (no emojis, no gendered language)

    @Test func noVoiceLinesContainEmojis() {
        let lines = [
            CatoPersona.sessionStart(exercise: "Squat", sets: 5, reps: 5, weight: 135.0, unit: "lbs"),
            CatoPersona.setComplete(setNumber: 1, reps: 5, weight: 135.0, unit: "lbs"),
            CatoPersona.setFailure(actual: 3, target: 5),
            CatoPersona.restStart(duration: 60),
            CatoPersona.restThirtySeconds(),
            CatoPersona.restTenSeconds(),
            CatoPersona.restComplete(),
            CatoPersona.sessionComplete(minutes: 30, exerciseCount: 3, totalSets: 9),
            CatoPersona.progressionIncrease(exercise: "Squat", newWeight: 140.0, unit: "lbs"),
            CatoPersona.deload(exercise: "Squat", newWeight: 120.0, unit: "lbs", sessions: 3),
            CatoPersona.trainingDayGreeting(dayName: "Leg Day"),
            CatoPersona.restDayGreeting(),
            CatoPersona.serverError(),
            CatoPersona.weightOverrideConfirmation(newWeight: 145.0, unit: "lbs"),
            CatoPersona.skipConfirmation(exercise: "Squat", nextExercise: "Deadlift"),
            CatoPersona.programCreated(name: "Test Program"),
            CatoPersona.programActivated(name: "Test Program"),
            CatoPersona.noProgramActive(),
            CatoPersona.programParseError(),
        ]
        for line in lines {
            // isEmojiPresentation catches actual rendered emoji (🎤 💪 etc)
            // but not text characters that happen to have emoji code points (apostrophes, etc.)
            let hasEmoji = line.unicodeScalars.contains { scalar in
                scalar.properties.isEmojiPresentation
            }
            #expect(!hasEmoji, "Voice line contains emoji: \(line)")
        }
    }

    @Test func noVoiceLinesContainGenderedLanguage() {
        let genderedTerms = ["he", "she", "him", "her", "his", "hers", "man", "woman", "guy", "girl", "dude", "bro"]
        let lines = [
            CatoPersona.sessionStart(exercise: "Test", sets: 3, reps: 10, weight: 100.0, unit: "lbs"),
            CatoPersona.setComplete(setNumber: 1, reps: 10, weight: 100.0, unit: "lbs"),
            CatoPersona.setFailure(actual: 8, target: 10),
            CatoPersona.restStart(duration: 60),
            CatoPersona.sessionComplete(minutes: 30, exerciseCount: 3, totalSets: 9),
            CatoPersona.trainingDayGreeting(dayName: "Test Day"),
            CatoPersona.restDayGreeting(),
            CatoPersona.programCreated(name: "Test"),
            CatoPersona.programActivated(name: "Test"),
            CatoPersona.noProgramActive(),
            CatoPersona.programParseError(),
        ]
        for line in lines {
            let lowercased = line.lowercased()
            for term in genderedTerms {
                // Check as whole word only
                let pattern = "\\b\(term)\\b"
                let hasGendered = lowercased.range(of: pattern, options: .regularExpression) != nil
                #expect(!hasGendered, "Voice line '\(line)' contains gendered term '\(term)'")
            }
        }
    }
}

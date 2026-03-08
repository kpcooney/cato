//
//  FoundationModelsService.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Workout program parsing from natural language using Apple Foundation Models.
//  Uses @Generable structs for structured output on iOS 26+, with an
//  unavailable fallback for older devices. The factory performs a runtime
//  #available check to pick the right implementation.
//

import Foundation

// MARK: - Protocol

/// Abstraction for workout program parsing from natural language.
/// The ProgramListView checks `isAvailable` to conditionally show the AI Builder option.
protocol WorkoutParsingServiceProtocol {
    /// Whether this device/OS supports AI-powered program parsing.
    var isAvailable: Bool { get }

    /// Parse natural language text into a draft program structure.
    func parseProgram(from input: String) async throws -> DraftProgram
}

// MARK: - Unavailable Fallback

/// Fallback for devices that don't support Foundation Models.
/// Always reports unavailable — the UI hides the AI builder option on these devices.
class UnavailableParsingService: WorkoutParsingServiceProtocol {
    var isAvailable: Bool { false }

    func parseProgram(from input: String) async throws -> DraftProgram {
        throw NSError(
            domain: "WorkoutParsing",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "AI program builder is not available on this device."]
        )
    }
}

// MARK: - Foundation Models Implementation

#if canImport(FoundationModels)
import FoundationModels

// Generable structs for structured output from the on-device model.
// These are intermediate representations parsed by Foundation Models,
// then converted to DraftProgram for the builder UI.

@available(iOS 26, *)
@Generable
struct ParsedProgram {
    @Guide(description: "The name of the workout program")
    var name: String

    @Guide(description: "Program type: strength, cardio, hybrid, flexibility, or custom")
    var programType: String

    @Guide(description: "The weeks in this program")
    var weeks: [ParsedWeek]
}

@available(iOS 26, *)
@Generable
struct ParsedWeek {
    @Guide(description: "Week number, starting from 1")
    var weekNumber: Int

    @Guide(description: "Whether this is a deload/recovery week")
    var isDeloadWeek: Bool

    @Guide(description: "The training days in this week")
    var days: [ParsedDay]
}

@available(iOS 26, *)
@Generable
struct ParsedDay {
    @Guide(description: "Day of week: monday, tuesday, wednesday, thursday, friday, saturday, or sunday")
    var dayOfWeek: String

    @Guide(description: "Day name like Push Day, Pull Day, Legs, Upper Body, Rest")
    var name: String

    @Guide(description: "Day type: training, rest, or activeRecovery")
    var dayType: String

    @Guide(description: "Exercises for this day, empty for rest days")
    var activities: [ParsedActivity]
}

@available(iOS 26, *)
@Generable
struct ParsedActivity {
    @Guide(description: "Exercise name, e.g. Barbell Bench Press, Squat, Deadlift")
    var activityName: String

    @Guide(description: "Number of sets", .range(1...20))
    var sets: Int

    @Guide(description: "Target reps per set", .range(1...100))
    var reps: Int

    @Guide(description: "Target weight in pounds, 0 for bodyweight exercises")
    var weight: Double

    @Guide(description: "Rest between sets in seconds", .range(0...300))
    var restBetweenSets: Int
}

@available(iOS 26, *)
class FoundationModelsService: WorkoutParsingServiceProtocol {

    var isAvailable: Bool {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            return true
        default:
            return false
        }
    }

    func parseProgram(from input: String) async throws -> DraftProgram {
        let session = LanguageModelSession(
            instructions: """
                You are a workout program parser. Given a natural language description \
                of a workout routine or program, extract the structured program data.

                Rules:
                - If a program name is not given, create a descriptive one.
                - Map exercises to their common full names (e.g. "bench" -> "Barbell Bench Press").
                - Default rest between sets: 60 seconds for isolation exercises, 90 seconds for \
                  compound exercises (squat, deadlift, bench press, overhead press, barbell row).
                - If weight is not specified, use 0 (bodyweight).
                - If sets/reps are not specified, default to 3 sets of 10 reps.
                - Assign appropriate day names (Push Day, Pull Day, Legs, Upper, Lower, Full Body, etc.).
                - For rest days, set dayType to "rest" with an empty activities array.
                - Program type should be "strength" unless the description clearly indicates otherwise.
                - Always include all 7 days of the week (Monday through Sunday). \
                  Days without training should be rest days.
                """
        )

        let response = try await session.respond(
            to: input,
            generating: ParsedProgram.self
        )

        return convertToDraft(response.content)
    }

    /// Convert Foundation Models parsed output to a DraftProgram.
    private func convertToDraft(_ parsed: ParsedProgram) -> DraftProgram {
        var draft = DraftProgram()
        draft.name = parsed.name
        draft.programType = parseProgramType(parsed.programType)
        draft.sourceType = .naturalLanguage

        draft.weeks = parsed.weeks.map { parsedWeek in
            var week = DraftWeek(weekNumber: parsedWeek.weekNumber, isDeloadWeek: parsedWeek.isDeloadWeek)

            week.days = parsedWeek.days.map { parsedDay in
                var day = DraftDay(
                    dayOfWeek: parseDayOfWeek(parsedDay.dayOfWeek),
                    dayType: parseDayType(parsedDay.dayType)
                )
                day.name = parsedDay.name

                day.activities = parsedDay.activities.enumerated().map { index, parsedActivity in
                    var activity = DraftActivity()
                    activity.activityName = parsedActivity.activityName
                    activity.sets = parsedActivity.sets
                    activity.reps = parsedActivity.reps
                    activity.weight = parsedActivity.weight
                    activity.weightUnit = .lbs
                    activity.restBetweenSets = TimeInterval(parsedActivity.restBetweenSets)
                    activity.orderIndex = index
                    return activity
                }

                return day
            }

            // Ensure all 7 days are present, filling in rest days for any missing
            let existingDays = Set(week.days.map { $0.dayOfWeek })
            for dayOfWeek in DayOfWeek.allCases where !existingDays.contains(dayOfWeek) {
                week.days.append(DraftDay(dayOfWeek: dayOfWeek, dayType: .rest))
            }
            week.days.sort { $0.dayOfWeek.rawValue < $1.dayOfWeek.rawValue }

            return week
        }

        // Ensure at least one week exists
        if draft.weeks.isEmpty {
            draft.weeks = [DraftWeek.defaultWeek(number: 1)]
        }

        return draft
    }

    private func parseProgramType(_ value: String) -> ProgramType {
        ProgramType(rawValue: value.lowercased()) ?? .strength
    }

    private func parseDayOfWeek(_ value: String) -> DayOfWeek {
        switch value.lowercased() {
        case "monday": return .monday
        case "tuesday": return .tuesday
        case "wednesday": return .wednesday
        case "thursday": return .thursday
        case "friday": return .friday
        case "saturday": return .saturday
        case "sunday": return .sunday
        default: return .monday
        }
    }

    private func parseDayType(_ value: String) -> DayType {
        switch value.lowercased() {
        case "training": return .training
        case "rest": return .rest
        case "activerecovery", "active_recovery": return .activeRecovery
        default: return .training
        }
    }
}
#endif

// MARK: - Factory

/// Creates the appropriate parsing service based on device capabilities.
/// Returns the Foundation Models implementation on iOS 26+, or the
/// unavailable fallback on older versions.
enum WorkoutParsingServiceFactory {
    static func makeService() -> WorkoutParsingServiceProtocol {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            return FoundationModelsService()
        }
        #endif
        return UnavailableParsingService()
    }
}

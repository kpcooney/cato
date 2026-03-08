//
//  Enums.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation

enum ProgramType: String, Codable {
    case strength
    case cardio
    case hybrid
    case flexibility
    case custom
}

enum SourceType: String, Codable {
    case manual
    case naturalLanguage
    case url
}

enum DayOfWeek: Int, Codable, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

enum DayType: String, Codable {
    case training
    case rest
    case activeRecovery
}

enum ActivityType: String, Codable {
    case strength
    case cardio
    case distance
    case timed
    case custom
}

enum TargetMetric: String, Codable {
    case reps
    case weight
    case distance
    case duration
    case pace
    case calories
    case heartRateZone
}

enum TargetUnit: String, Codable {
    case count
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
    case bpm
}

enum ProgressionType: String, Codable {
    case percentage
    case fixedIncrement
    case repIncrease
}

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

enum ProgressionFrequency: String, Codable {
    case perSession
    case perWeek
    case perCycle
}

enum ConditionType: String, Codable {
    case allTargetsMet
    case rpeBelow
    case custom
}

enum SessionStatus: String, Codable {
    case inProgress
    case completed
    case abandoned
}

// MARK: - Display Names

extension DayOfWeek {
    /// User-facing name for display in views and forms.
    var displayName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    /// Short abbreviation for compact UI.
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

extension DayType {
    /// User-facing name for display in pickers and labels.
    var displayName: String {
        switch self {
        case .training: return "Training"
        case .rest: return "Rest"
        case .activeRecovery: return "Active Recovery"
        }
    }
}

extension ProgramType {
    /// User-facing name for display in pickers and labels.
    var displayName: String {
        rawValue.capitalized
    }
}

extension ActivityType {
    /// User-facing name for display in pickers and labels.
    var displayName: String {
        rawValue.capitalized
    }
}

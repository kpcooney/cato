//
//  FoundationModelsService.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Protocol and factory for workout program parsing from natural language.
//  Uses Apple Foundation Models (iOS 26+) when available, with a fallback
//  for older devices. Full Foundation Models implementation in Commit 7.
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

// MARK: - Factory

/// Creates the appropriate parsing service based on device capabilities.
/// Returns the Foundation Models implementation on iOS 26+, or the
/// unavailable fallback on older versions.
enum WorkoutParsingServiceFactory {
    static func makeService() -> WorkoutParsingServiceProtocol {
        // Full Foundation Models implementation will be added in Commit 7.
        // For now, always return the unavailable fallback.
        return UnavailableParsingService()
    }
}

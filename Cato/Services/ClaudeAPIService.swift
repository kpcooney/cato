//
//  ClaudeAPIService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

// MARK: - DEPRECATED — This file will be deleted in Phase 2.
//
// Original plan: use the Anthropic Messages API (Claude) for workout program parsing.
// Decision (2026-02-17): replaced with Apple Foundation Models (`FoundationModelsService`)
// which runs fully on-device, requires no API key, and is private by design.
//
// See: Cato/Services/FoundationModelsService.swift (added in Phase 2).
// This file is kept in git history for reference but will not be compiled in Phase 2+.

protocol ClaudeAPIServiceProtocol {
    func parseWorkoutProgram(input: String, isURL: Bool) async throws -> WorkoutProgram
}

@available(*, deprecated, renamed: "FoundationModelsService",
           message: "Replaced by on-device Apple Foundation Models in Phase 2.")
class ClaudeAPIService: ClaudeAPIServiceProtocol {

    private let apiKey: String

    // Anthropic Messages API endpoint. Unused — see deprecation notice above.
    private let endpoint = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-20250514"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func parseWorkoutProgram(input: String, isURL: Bool) async throws -> WorkoutProgram {
        // Stub — intentionally not implemented. This service is deprecated.
        throw NSError(domain: "ClaudeAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented — use FoundationModelsService"])
    }
}

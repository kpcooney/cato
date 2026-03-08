//
//  ClaudeAPIService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation

protocol ClaudeAPIServiceProtocol {
    func parseWorkoutProgram(input: String, isURL: Bool) async throws -> WorkoutProgram
}

class ClaudeAPIService: ClaudeAPIServiceProtocol {

    private let apiKey: String
    private let endpoint = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-20250514"

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func parseWorkoutProgram(input: String, isURL: Bool) async throws -> WorkoutProgram {
        // Stub: Will call Claude API to parse natural language or URL into structured WorkoutProgram
        throw NSError(domain: "ClaudeAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}

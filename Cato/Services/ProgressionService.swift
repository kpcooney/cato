//
//  ProgressionService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation

protocol ProgressionServiceProtocol {
    func evaluateProgression(
        for activity: ProgramActivity,
        completedSets: [CompletedSet],
        rule: ProgressionRule
    ) -> ProgressionEvent?
}

class ProgressionService: ProgressionServiceProtocol {

    func evaluateProgression(
        for activity: ProgramActivity,
        completedSets: [CompletedSet],
        rule: ProgressionRule
    ) -> ProgressionEvent? {
        // Stub: Evaluate progression rules and return ProgressionEvent if triggered
        return nil
    }
}

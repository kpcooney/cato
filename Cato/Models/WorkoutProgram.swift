//
//  WorkoutProgram.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class WorkoutProgram {
    var id: UUID
    var name: String
    var programDescription: String?
    var programType: ProgramType
    var sourceType: SourceType
    var sourceText: String?
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool

    @Relationship(deleteRule: .cascade)
    var weeks: [ProgramWeek]

    @Relationship(deleteRule: .cascade)
    var defaultProgressionRules: [ProgressionRule]

    init(
        id: UUID = UUID(),
        name: String,
        programDescription: String? = nil,
        programType: ProgramType,
        sourceType: SourceType,
        sourceText: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = false,
        weeks: [ProgramWeek] = [],
        defaultProgressionRules: [ProgressionRule] = []
    ) {
        self.id = id
        self.name = name
        self.programDescription = programDescription
        self.programType = programType
        self.sourceType = sourceType
        self.sourceText = sourceText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.weeks = weeks
        self.defaultProgressionRules = defaultProgressionRules
    }
}

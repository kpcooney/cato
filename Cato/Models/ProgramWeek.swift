//
//  ProgramWeek.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ProgramWeek {
    var id: UUID
    var weekNumber: Int
    var isDeloadWeek: Bool

    @Relationship(deleteRule: .cascade)
    var days: [ProgramDay]

    var program: WorkoutProgram?

    init(
        id: UUID = UUID(),
        weekNumber: Int,
        isDeloadWeek: Bool = false,
        days: [ProgramDay] = [],
        program: WorkoutProgram? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.isDeloadWeek = isDeloadWeek
        self.days = days
        self.program = program
    }
}

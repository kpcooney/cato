//
//  ProgramDay.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ProgramDay {
    var id: UUID
    var dayOfWeek: DayOfWeek
    var name: String?
    var dayType: DayType
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var activities: [ProgramActivity]

    var week: ProgramWeek?

    init(
        id: UUID = UUID(),
        dayOfWeek: DayOfWeek,
        name: String? = nil,
        dayType: DayType,
        notes: String? = nil,
        activities: [ProgramActivity] = [],
        week: ProgramWeek? = nil
    ) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.name = name
        self.dayType = dayType
        self.notes = notes
        self.activities = activities
        self.week = week
    }
}

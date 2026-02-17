//
//  WorkoutSession.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class WorkoutSession {
    var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date?
    var status: SessionStatus
    var notes: String?

    var program: WorkoutProgram?
    var programDay: ProgramDay?

    @Relationship(deleteRule: .cascade)
    var completedActivities: [CompletedActivity]

    @Relationship(deleteRule: .cascade)
    var healthMetrics: SessionHealthMetrics?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        status: SessionStatus,
        notes: String? = nil,
        program: WorkoutProgram? = nil,
        programDay: ProgramDay? = nil,
        completedActivities: [CompletedActivity] = [],
        healthMetrics: SessionHealthMetrics? = nil
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.notes = notes
        self.program = program
        self.programDay = programDay
        self.completedActivities = completedActivities
        self.healthMetrics = healthMetrics
    }
}

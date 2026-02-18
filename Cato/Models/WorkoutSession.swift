//
//  WorkoutSession.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// An instance of the user performing a training day. Created when the user taps
/// "Start Workout" and updated as they log sets throughout the session.
///
/// Sessions are permanently retained for history — they are never deleted automatically.
/// The program and programDay relationships are soft references (optional) so that
/// deleting a program does not destroy historical session data.
@Model
class WorkoutSession {
    var id: UUID

    /// Calendar date the session took place. Separate from startTime to allow
    /// easy date-based filtering without time-zone edge cases.
    var date: Date

    var startTime: Date

    /// nil until the session is completed or abandoned. Used to calculate duration.
    var endTime: Date?

    /// Current lifecycle state. Sessions persisted as inProgress on a previous launch
    /// should be shown to the user as potentially abandoned.
    var status: SessionStatus

    var notes: String?

    /// Soft reference — retained even if the program is later deleted, so history
    /// can still display the program name from the denormalized activity names.
    var program: WorkoutProgram?

    /// The specific day template this session was based on.
    var programDay: ProgramDay?

    /// The actual exercises performed, in the order they were completed.
    /// Cascade delete: removing a session removes all its completed activities.
    @Relationship(deleteRule: .cascade)
    var completedActivities: [CompletedActivity]

    /// Heart rate and calorie data from Apple Watch, if available.
    /// nil when the user has no Watch or HealthKit permission was denied.
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

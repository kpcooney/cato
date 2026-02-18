//
//  ProgramDay.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// One day within a ProgramWeek, mapped to a specific day of the week.
///
/// Training days have a list of activities; rest/recovery days have none.
/// The session scheduler uses dayOfWeek to find which ProgramDay matches today's date.
@Model
class ProgramDay {
    var id: UUID

    /// Which calendar day this training day falls on (e.g. .monday, .wednesday).
    /// Used by the session scheduler to surface the correct day on the Today tab.
    var dayOfWeek: DayOfWeek

    /// Optional friendly name shown in the UI (e.g. "Push Day", "Leg Day", "Rest").
    /// Defaults to nil; the UI falls back to the dayOfWeek label when nil.
    var name: String?

    /// Whether the day has training, rest, or active recovery.
    /// Determines whether the Today tab shows a Start Workout button or a rest message.
    var dayType: DayType

    var notes: String?

    /// The exercises prescribed for this day. Empty for rest/recovery days.
    /// Cascade delete ensures orphaned activities are removed if the day is deleted.
    @Relationship(deleteRule: .cascade)
    var activities: [ProgramActivity]

    /// Back-reference to the parent week.
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

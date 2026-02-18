//
//  ProgramWeek.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import SwiftData

/// One week within a WorkoutProgram. Programs may have multiple weeks for
/// periodized or progressive structures (e.g. a 12-week block).
///
/// Weeks are 1-indexed (weekNumber starts at 1) and ordered by weekNumber in the UI.
/// After the last week completes, the program loops back to week 1.
@Model
class ProgramWeek {
    /// 1-based index. Determines display order and loop position in session scheduling.
    var id: UUID
    var weekNumber: Int

    /// Deload weeks use reduced volume/intensity to allow recovery.
    /// When true, the session UI may display a deload banner and the
    /// ProgressionService skips progression evaluation for this week.
    var isDeloadWeek: Bool

    /// Cascade delete: removing a week removes all its days and their activities.
    @Relationship(deleteRule: .cascade)
    var days: [ProgramDay]

    /// Back-reference to the parent program (nil if not yet inserted).
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

//
//  CompletedActivity.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class CompletedActivity {
    var id: UUID
    var activityName: String
    var activityType: ActivityType
    var skipped: Bool
    var notes: String?

    var programActivity: ProgramActivity?
    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade)
    var sets: [CompletedSet]

    @Relationship(deleteRule: .cascade)
    var completedTargets: [CompletedTarget]

    init(
        id: UUID = UUID(),
        activityName: String,
        activityType: ActivityType,
        skipped: Bool = false,
        notes: String? = nil,
        programActivity: ProgramActivity? = nil,
        session: WorkoutSession? = nil,
        sets: [CompletedSet] = [],
        completedTargets: [CompletedTarget] = []
    ) {
        self.id = id
        self.activityName = activityName
        self.activityType = activityType
        self.skipped = skipped
        self.notes = notes
        self.programActivity = programActivity
        self.session = session
        self.sets = sets
        self.completedTargets = completedTargets
    }
}

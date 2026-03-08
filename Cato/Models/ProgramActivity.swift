//
//  ProgramActivity.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import SwiftData

@Model
class ProgramActivity {
    var id: UUID
    var activityName: String
    var activityType: ActivityType
    var orderIndex: Int
    var restBetweenSets: TimeInterval?
    var restAfterActivity: TimeInterval?
    var notes: String?

    @Relationship(deleteRule: .cascade)
    var targets: [ActivityTarget]

    var progressionRuleOverride: ProgressionRule?
    var day: ProgramDay?

    init(
        id: UUID = UUID(),
        activityName: String,
        activityType: ActivityType,
        orderIndex: Int,
        restBetweenSets: TimeInterval? = nil,
        restAfterActivity: TimeInterval? = nil,
        notes: String? = nil,
        targets: [ActivityTarget] = [],
        progressionRuleOverride: ProgressionRule? = nil,
        day: ProgramDay? = nil
    ) {
        self.id = id
        self.activityName = activityName
        self.activityType = activityType
        self.orderIndex = orderIndex
        self.restBetweenSets = restBetweenSets
        self.restAfterActivity = restAfterActivity
        self.notes = notes
        self.targets = targets
        self.progressionRuleOverride = progressionRuleOverride
        self.day = day
    }
}

//
//  DraftModels.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Plain value-type structs used during program creation and editing.
//  These mirror the SwiftData @Model hierarchy but avoid persistence concerns —
//  no orphaned objects if the user cancels, no ModelContext required.
//  Convert to @Model objects only when the user confirms and saves.
//

import Foundation

// MARK: - Draft Program

/// Top-level draft representing a workout program being created or edited.
struct DraftProgram: Identifiable {
    var id = UUID()
    var name: String = ""
    var programDescription: String = ""
    var programType: ProgramType = .strength
    var sourceType: SourceType = .manual
    var sourceText: String?
    var weeks: [DraftWeek] = []

    /// Creates a default program with one week (Mon-Sun, all rest).
    static func defaultProgram() -> DraftProgram {
        var draft = DraftProgram()
        draft.weeks = [DraftWeek.defaultWeek(number: 1)]
        return draft
    }
}

// MARK: - Draft Week

struct DraftWeek: Identifiable {
    var id = UUID()
    var weekNumber: Int
    var isDeloadWeek: Bool = false
    var days: [DraftDay] = []

    /// Creates a week with all 7 days set to rest by default.
    static func defaultWeek(number: Int) -> DraftWeek {
        DraftWeek(
            weekNumber: number,
            days: DayOfWeek.allCases.map { dayOfWeek in
                DraftDay(dayOfWeek: dayOfWeek, dayType: .rest)
            }
        )
    }
}

// MARK: - Draft Day

struct DraftDay: Identifiable {
    var id = UUID()
    var dayOfWeek: DayOfWeek
    var name: String = ""
    var dayType: DayType
    var notes: String = ""
    var activities: [DraftActivity] = []
}

// MARK: - Draft Activity

/// Represents a single exercise being configured.
/// Exposes flat sets/reps/weight properties for v1 strength UI simplicity,
/// while converting to the flexible ActivityTarget pattern via `toTargets()`.
struct DraftActivity: Identifiable {
    var id = UUID()
    var activityName: String = ""
    var activityType: ActivityType = .strength
    var orderIndex: Int = 0
    var sets: Int = 3
    var reps: Int = 10
    var weight: Double = 0
    var weightUnit: TargetUnit = .lbs
    var restBetweenSets: TimeInterval = 60
    var restAfterActivity: TimeInterval? = nil
    var notes: String = ""

    /// Convert the flat sets/reps/weight into the flexible ActivityTarget pattern.
    /// Always produces a reps target; only produces a weight target if weight > 0
    /// (bodyweight exercises have no weight target).
    func toTargets() -> [DraftTarget] {
        var targets: [DraftTarget] = []
        targets.append(DraftTarget(metric: .reps, value: Double(reps), unit: .count, repeatCount: sets))
        if weight > 0 {
            targets.append(DraftTarget(metric: .weight, value: weight, unit: weightUnit, repeatCount: nil))
        }
        return targets
    }
}

// MARK: - Draft Target

struct DraftTarget: Identifiable {
    var id = UUID()
    var metric: TargetMetric
    var value: Double
    var unit: TargetUnit
    var repeatCount: Int?
}

// MARK: - Conversion: Draft → SwiftData @Model

extension DraftProgram {
    /// Convert this draft to a SwiftData WorkoutProgram with full object graph.
    /// The caller is responsible for inserting the returned object into a ModelContext.
    func toWorkoutProgram() -> WorkoutProgram {
        let program = WorkoutProgram(
            name: name,
            programDescription: programDescription.isEmpty ? nil : programDescription,
            programType: programType,
            sourceType: sourceType,
            sourceText: sourceText
        )

        program.weeks = weeks.map { draftWeek in
            let week = ProgramWeek(
                weekNumber: draftWeek.weekNumber,
                isDeloadWeek: draftWeek.isDeloadWeek
            )
            week.program = program

            week.days = draftWeek.days.map { draftDay in
                let day = ProgramDay(
                    dayOfWeek: draftDay.dayOfWeek,
                    name: draftDay.name.isEmpty ? nil : draftDay.name,
                    dayType: draftDay.dayType,
                    notes: draftDay.notes.isEmpty ? nil : draftDay.notes
                )
                day.week = week

                day.activities = draftDay.activities.enumerated().map { index, draftActivity in
                    let activity = ProgramActivity(
                        activityName: draftActivity.activityName,
                        activityType: draftActivity.activityType,
                        orderIndex: index,
                        restBetweenSets: draftActivity.restBetweenSets,
                        restAfterActivity: draftActivity.restAfterActivity,
                        notes: draftActivity.notes.isEmpty ? nil : draftActivity.notes
                    )
                    activity.day = day

                    activity.targets = draftActivity.toTargets().map { draftTarget in
                        let target = ActivityTarget(
                            metric: draftTarget.metric,
                            value: draftTarget.value,
                            unit: draftTarget.unit,
                            repeatCount: draftTarget.repeatCount
                        )
                        target.activity = activity
                        return target
                    }

                    return activity
                }

                return day
            }

            return week
        }

        return program
    }
}

// MARK: - Conversion: SwiftData @Model → Draft

extension DraftProgram {
    /// Create a draft from an existing WorkoutProgram for editing or duplicating.
    /// Pass a custom `newName` when duplicating to avoid name collisions.
    static func from(program: WorkoutProgram, newName: String? = nil) -> DraftProgram {
        var draft = DraftProgram()
        draft.name = newName ?? program.name
        draft.programDescription = program.programDescription ?? ""
        draft.programType = program.programType
        draft.sourceType = program.sourceType
        draft.sourceText = program.sourceText

        draft.weeks = program.weeks
            .sorted { $0.weekNumber < $1.weekNumber }
            .map { week in
                var draftWeek = DraftWeek(weekNumber: week.weekNumber, isDeloadWeek: week.isDeloadWeek)
                draftWeek.days = week.days
                    .sorted { $0.dayOfWeek.rawValue < $1.dayOfWeek.rawValue }
                    .map { day in
                        var draftDay = DraftDay(dayOfWeek: day.dayOfWeek, dayType: day.dayType)
                        draftDay.name = day.name ?? ""
                        draftDay.notes = day.notes ?? ""
                        draftDay.activities = day.activities
                            .sorted { $0.orderIndex < $1.orderIndex }
                            .map { activity in
                                var draftActivity = DraftActivity()
                                draftActivity.activityName = activity.activityName
                                draftActivity.activityType = activity.activityType
                                draftActivity.orderIndex = activity.orderIndex
                                draftActivity.restBetweenSets = activity.restBetweenSets ?? 60
                                draftActivity.restAfterActivity = activity.restAfterActivity
                                draftActivity.notes = activity.notes ?? ""

                                // Extract sets/reps/weight from the flexible target system
                                let repsTarget = activity.targets.first { $0.metric == .reps }
                                let weightTarget = activity.targets.first { $0.metric == .weight }
                                draftActivity.sets = repsTarget?.repeatCount ?? 3
                                draftActivity.reps = Int(repsTarget?.value ?? 10)
                                draftActivity.weight = weightTarget?.value ?? 0
                                draftActivity.weightUnit = weightTarget?.unit ?? .lbs

                                return draftActivity
                            }
                        return draftDay
                    }
                return draftWeek
            }

        return draft
    }
}

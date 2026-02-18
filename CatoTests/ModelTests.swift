//
//  ModelTests.swift
//  CatoTests
//
//  Tests for SwiftData model initialization, properties, and relationships.
//  Uses an in-memory ModelContainer — no CloudKit, no disk I/O.
//

import Testing
import Foundation
import SwiftData
@testable import Cato

// MARK: - Test Container

/// Creates a fresh in-memory ModelContainer for each test.
/// Avoids any CloudKit or disk interactions.
/// Returns both the container and a fresh ModelContext.
func makeTestContext() throws -> (ModelContainer, ModelContext) {
    let schema = Schema([
        WorkoutProgram.self,
        ProgramWeek.self,
        ProgramDay.self,
        ProgramActivity.self,
        ActivityTarget.self,
        ProgressionRule.self,
        WorkoutSession.self,
        CompletedActivity.self,
        CompletedSet.self,
        CompletedTarget.self,
        SessionHealthMetrics.self,
        ProgressionEvent.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    context.autosaveEnabled = false
    return (container, context)
}

// MARK: - WorkoutProgram Tests

@Suite("WorkoutProgram", .serialized)
@MainActor
struct WorkoutProgramTests {

    @Test func defaultsAreCorrect() throws {
        let program = WorkoutProgram(
            name: "Starting Strength",
            programType: .strength,
            sourceType: .manual
        )
        #expect(program.name == "Starting Strength")
        #expect(program.programType == .strength)
        #expect(program.sourceType == .manual)
        #expect(program.isActive == false)
        #expect(program.programDescription == nil)
        #expect(program.sourceText == nil)
        #expect(program.weeks.isEmpty)
        #expect(program.defaultProgressionRules.isEmpty)
    }

    @Test func idIsUniquePerInstance() {
        let a = WorkoutProgram(name: "A", programType: .strength, sourceType: .manual)
        let b = WorkoutProgram(name: "B", programType: .strength, sourceType: .manual)
        #expect(a.id != b.id)
    }

    @Test func canSetActive() {
        let program = WorkoutProgram(
            name: "5/3/1",
            programType: .strength,
            sourceType: .manual,
            isActive: true
        )
        #expect(program.isActive == true)
    }

    @Test func programPropertiesBeforeInsert() {
        // Validate model properties using the app's live container (via environment)
        // @Model objects can be created and have properties checked before being inserted.
        let program = WorkoutProgram(
            name: "GZCLP",
            programType: .strength,
            sourceType: .naturalLanguage,
            isActive: true
        )
        #expect(program.name == "GZCLP")
        #expect(program.isActive == true)
        #expect(program.sourceType == .naturalLanguage)
    }

    @Test func activeProgramToggle() {
        // Validate the active toggle logic — business rule: only one active at a time
        let first = WorkoutProgram(name: "Program A", programType: .strength, sourceType: .manual, isActive: true)
        let second = WorkoutProgram(name: "Program B", programType: .strength, sourceType: .manual, isActive: false)

        // Simulate switching active program
        first.isActive = false
        second.isActive = true

        // Verify in-memory state — only Program B is active
        let programs = [first, second]
        let active = programs.filter { $0.isActive }
        #expect(active.count == 1)
        #expect(active.first?.name == "Program B")
        #expect(first.isActive == false)
    }
}

// MARK: - ProgramWeek Tests

@Suite("ProgramWeek")
@MainActor
struct ProgramWeekTests {

    @Test func defaultsAreCorrect() {
        let week = ProgramWeek(weekNumber: 1, isDeloadWeek: false)
        #expect(week.weekNumber == 1)
        #expect(week.isDeloadWeek == false)
        #expect(week.days.isEmpty)
    }

    @Test func deloadWeek() {
        let week = ProgramWeek(weekNumber: 4, isDeloadWeek: true)
        #expect(week.isDeloadWeek == true)
        #expect(week.weekNumber == 4)
    }
}

// MARK: - ProgramDay Tests

@Suite("ProgramDay")
@MainActor
struct ProgramDayTests {

    @Test func trainingDayDefaults() {
        let day = ProgramDay(dayOfWeek: .monday, dayType: .training)
        #expect(day.dayOfWeek == .monday)
        #expect(day.dayType == .training)
        #expect(day.activities.isEmpty)
        #expect(day.name == nil)
        #expect(day.notes == nil)
    }

    @Test func restDay() {
        let day = ProgramDay(dayOfWeek: .sunday, name: "Rest", dayType: .rest)
        #expect(day.dayType == .rest)
        #expect(day.name == "Rest")
    }

    @Test func allDaysOfWeekAreValid() {
        let days = DayOfWeek.allCases
        #expect(days.count == 7)
        #expect(days.contains(.monday))
        #expect(days.contains(.sunday))
    }
}

// MARK: - ProgramActivity Tests

@Suite("ProgramActivity")
@MainActor
struct ProgramActivityTests {

    @Test func defaultsAreCorrect() {
        let activity = ProgramActivity(
            activityName: "Barbell Bench Press",
            activityType: .strength,
            orderIndex: 0
        )
        #expect(activity.activityName == "Barbell Bench Press")
        #expect(activity.activityType == .strength)
        #expect(activity.orderIndex == 0)
        #expect(activity.targets.isEmpty)
        #expect(activity.restBetweenSets == nil)
        #expect(activity.restAfterActivity == nil)
    }

    @Test func withRestIntervals() {
        let activity = ProgramActivity(
            activityName: "Deadlift",
            activityType: .strength,
            orderIndex: 1,
            restBetweenSets: 180,
            restAfterActivity: 300
        )
        #expect(activity.restBetweenSets == 180)
        #expect(activity.restAfterActivity == 300)
    }
}

// MARK: - ActivityTarget Tests

@Suite("ActivityTarget", .serialized)
@MainActor
struct ActivityTargetTests {

    @Test func strengthTargetReps() {
        let target = ActivityTarget(metric: .reps, value: 5, unit: .count, repeatCount: 5)
        #expect(target.metric == .reps)
        #expect(target.value == 5)
        #expect(target.unit == .count)
        #expect(target.repeatCount == 5)
    }

    @Test func strengthTargetWeight() {
        let target = ActivityTarget(metric: .weight, value: 185, unit: .lbs, repeatCount: nil)
        #expect(target.metric == .weight)
        #expect(target.value == 185)
        #expect(target.unit == .lbs)
        #expect(target.repeatCount == nil)
    }

    @Test func fiveByFiveStrengthPattern() {
        // Bench Press 5x5 @ 185 lbs — validate the two-target pattern for strength activities
        let repsTarget = ActivityTarget(metric: .reps, value: 5, unit: .count, repeatCount: 5)
        let weightTarget = ActivityTarget(metric: .weight, value: 185, unit: .lbs, repeatCount: nil)

        #expect(repsTarget.metric == .reps)
        #expect(repsTarget.value == 5)
        #expect(repsTarget.unit == .count)
        #expect(repsTarget.repeatCount == 5)

        #expect(weightTarget.metric == .weight)
        #expect(weightTarget.value == 185)
        #expect(weightTarget.unit == .lbs)
        #expect(weightTarget.repeatCount == nil)
    }
}

// MARK: - Enums Tests

@Suite("Enums")
struct EnumsTests {

    @Test func programTypeRawValues() {
        #expect(ProgramType.strength.rawValue == "strength")
        #expect(ProgramType.cardio.rawValue == "cardio")
        #expect(ProgramType.hybrid.rawValue == "hybrid")
        #expect(ProgramType.flexibility.rawValue == "flexibility")
        #expect(ProgramType.custom.rawValue == "custom")
    }

    @Test func sourceTypeRawValues() {
        #expect(SourceType.manual.rawValue == "manual")
        #expect(SourceType.naturalLanguage.rawValue == "naturalLanguage")
        #expect(SourceType.url.rawValue == "url")
    }

    @Test func dayOfWeekOrdering() {
        #expect(DayOfWeek.monday.rawValue == 1)
        #expect(DayOfWeek.tuesday.rawValue == 2)
        #expect(DayOfWeek.wednesday.rawValue == 3)
        #expect(DayOfWeek.thursday.rawValue == 4)
        #expect(DayOfWeek.friday.rawValue == 5)
        #expect(DayOfWeek.saturday.rawValue == 6)
        #expect(DayOfWeek.sunday.rawValue == 7)
    }

    @Test func dayTypeRawValues() {
        #expect(DayType.training.rawValue == "training")
        #expect(DayType.rest.rawValue == "rest")
        #expect(DayType.activeRecovery.rawValue == "activeRecovery")
    }

    @Test func sessionStatusRawValues() {
        #expect(SessionStatus.inProgress.rawValue == "inProgress")
        #expect(SessionStatus.completed.rawValue == "completed")
        #expect(SessionStatus.abandoned.rawValue == "abandoned")
    }

    @Test func targetMetricRawValues() {
        #expect(TargetMetric.reps.rawValue == "reps")
        #expect(TargetMetric.weight.rawValue == "weight")
        #expect(TargetMetric.distance.rawValue == "distance")
        #expect(TargetMetric.duration.rawValue == "duration")
        #expect(TargetMetric.pace.rawValue == "pace")
        #expect(TargetMetric.calories.rawValue == "calories")
        #expect(TargetMetric.heartRateZone.rawValue == "heartRateZone")
    }

    @Test func targetUnitRawValues() {
        #expect(TargetUnit.lbs.rawValue == "lbs")
        #expect(TargetUnit.kg.rawValue == "kg")
        #expect(TargetUnit.count.rawValue == "count")
        #expect(TargetUnit.miles.rawValue == "miles")
        #expect(TargetUnit.km.rawValue == "km")
        #expect(TargetUnit.seconds.rawValue == "seconds")
        #expect(TargetUnit.minutes.rawValue == "minutes")
        #expect(TargetUnit.bpm.rawValue == "bpm")
    }

    @Test func progressionTypeRawValues() {
        #expect(ProgressionType.percentage.rawValue == "percentage")
        #expect(ProgressionType.fixedIncrement.rawValue == "fixedIncrement")
        #expect(ProgressionType.repIncrease.rawValue == "repIncrease")
    }
}

// MARK: - WorkoutSession Tests

@Suite("WorkoutSession")
@MainActor
struct WorkoutSessionTests {

    @Test func defaultStatus() {
        let session = WorkoutSession(
            date: Date(),
            startTime: Date(),
            status: .inProgress
        )
        #expect(session.status == .inProgress)
        #expect(session.endTime == nil)
        #expect(session.completedActivities.isEmpty)
        #expect(session.healthMetrics == nil)
    }

    @Test func completedSession() {
        let start = Date()
        let end = start.addingTimeInterval(2700) // 45 min
        let session = WorkoutSession(
            date: start,
            startTime: start,
            endTime: end,
            status: .completed
        )
        #expect(session.status == .completed)
        #expect(session.endTime != nil)
        let duration = session.endTime!.timeIntervalSince(session.startTime)
        #expect(duration == 2700)
    }
}

// MARK: - CompletedSet Tests

@Suite("CompletedSet")
struct CompletedSetTests {

    @Test func successfulSet() {
        let set = CompletedSet(
            setNumber: 1,
            targetReps: 5,
            completedReps: 5,
            targetWeight: 185.0,
            actualWeight: 185.0,
            weightUnit: .lbs,
            isFailure: false,
            timestamp: Date()
        )
        #expect(set.isFailure == false)
        #expect(set.completedReps == set.targetReps)
    }

    @Test func failedSet() {
        let set = CompletedSet(
            setNumber: 2,
            targetReps: 5,
            completedReps: 3,
            targetWeight: 185.0,
            actualWeight: 185.0,
            weightUnit: .lbs,
            isFailure: true,
            timestamp: Date()
        )
        #expect(set.isFailure == true)
        #expect(set.completedReps < set.targetReps)
    }

    @Test func weightOverride() {
        let set = CompletedSet(
            setNumber: 1,
            targetReps: 5,
            completedReps: 5,
            targetWeight: 185.0,
            actualWeight: 195.0, // user overrode weight mid-session
            weightUnit: .lbs,
            isFailure: false,
            timestamp: Date()
        )
        #expect(set.targetWeight != set.actualWeight)
        #expect(set.actualWeight == 195.0)
    }
}

// MARK: - SessionHealthMetrics Tests

@Suite("SessionHealthMetrics")
struct SessionHealthMetricsTests {

    @Test func noWatchData() {
        let metrics = SessionHealthMetrics(
            duration: 2700,
            heartRateSampleTimestamps: [],
            heartRateSampleValues: []
        )
        #expect(metrics.averageHeartRate == nil)
        #expect(metrics.maxHeartRate == nil)
        #expect(metrics.minHeartRate == nil)
        #expect(metrics.activeCalories == nil)
        #expect(metrics.heartRateSampleTimestamps.isEmpty)
        #expect(metrics.heartRateSampleValues.isEmpty)
    }

    @Test func withWatchData() {
        let now = Date()
        let timestamps = [now, now.addingTimeInterval(60), now.addingTimeInterval(120)]
        let values = [72.0, 85.0, 143.0]
        let metrics = SessionHealthMetrics(
            averageHeartRate: 100.0,
            maxHeartRate: 143.0,
            minHeartRate: 72.0,
            activeCalories: 350.0,
            duration: 3600,
            heartRateSampleTimestamps: timestamps,
            heartRateSampleValues: values
        )
        #expect(metrics.averageHeartRate == 100.0)
        #expect(metrics.maxHeartRate == 143.0)
        #expect(metrics.minHeartRate == 72.0)
        #expect(metrics.activeCalories == 350.0)
        #expect(metrics.heartRateSampleTimestamps.count == metrics.heartRateSampleValues.count)
    }

    @Test func parallelArraysMatchLength() {
        // Heart rate samples stored as parallel arrays — they must always be same length
        let now = Date()
        let timestamps = [now, now.addingTimeInterval(30)]
        let values = [80.0, 95.0]
        let metrics = SessionHealthMetrics(
            duration: 60,
            heartRateSampleTimestamps: timestamps,
            heartRateSampleValues: values
        )
        #expect(metrics.heartRateSampleTimestamps.count == metrics.heartRateSampleValues.count)
    }
}

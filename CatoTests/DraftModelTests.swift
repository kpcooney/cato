//
//  DraftModelTests.swift
//  CatoTests
//
//  Created by Claude Code on 2026-03-08.
//
//  Tests for DraftModels: creation defaults, target conversion,
//  and round-trip conversion between Draft and SwiftData @Model objects.
//

import Testing
import Foundation
@testable import Cato

// MARK: - DraftProgram Tests

@Suite("DraftProgram")
struct DraftProgramTests {

    @Test func defaultProgram_hasOneWeekWithSevenDays() {
        let draft = DraftProgram.defaultProgram()
        #expect(draft.weeks.count == 1)
        #expect(draft.weeks[0].days.count == 7)
        #expect(draft.weeks[0].weekNumber == 1)
    }

    @Test func defaultProgram_allDaysAreRest() {
        let draft = DraftProgram.defaultProgram()
        for day in draft.weeks[0].days {
            #expect(day.dayType == .rest)
        }
    }

    @Test func defaultProgram_daysOrderedMondayThroughSunday() {
        let draft = DraftProgram.defaultProgram()
        let dayValues = draft.weeks[0].days.map { $0.dayOfWeek.rawValue }
        #expect(dayValues == [1, 2, 3, 4, 5, 6, 7])
    }

    @Test func defaultProgram_hasDefaultValues() {
        let draft = DraftProgram.defaultProgram()
        #expect(draft.name == "")
        #expect(draft.programDescription == "")
        #expect(draft.programType == .strength)
        #expect(draft.sourceType == .manual)
        #expect(draft.sourceText == nil)
    }
}

// MARK: - DraftActivity Target Conversion

@Suite("DraftActivity Targets")
struct DraftActivityTargetTests {

    @Test func strengthActivity_producesRepsAndWeightTargets() {
        var activity = DraftActivity()
        activity.sets = 5
        activity.reps = 5
        activity.weight = 185
        activity.weightUnit = .lbs

        let targets = activity.toTargets()
        #expect(targets.count == 2)

        // Reps target
        let repsTarget = targets.first { $0.metric == .reps }
        #expect(repsTarget != nil)
        #expect(repsTarget?.value == 5)
        #expect(repsTarget?.unit == .count)
        #expect(repsTarget?.repeatCount == 5) // 5 sets

        // Weight target
        let weightTarget = targets.first { $0.metric == .weight }
        #expect(weightTarget != nil)
        #expect(weightTarget?.value == 185)
        #expect(weightTarget?.unit == .lbs)
        #expect(weightTarget?.repeatCount == nil)
    }

    @Test func bodyweightActivity_producesOnlyRepsTarget() {
        // Push-ups: no weight
        var activity = DraftActivity()
        activity.sets = 3
        activity.reps = 15
        activity.weight = 0 // bodyweight

        let targets = activity.toTargets()
        #expect(targets.count == 1)
        #expect(targets[0].metric == .reps)
        #expect(targets[0].value == 15)
        #expect(targets[0].repeatCount == 3)
    }

    @Test func kilogramUnit_propagatesToTarget() {
        var activity = DraftActivity()
        activity.weight = 80
        activity.weightUnit = .kg

        let targets = activity.toTargets()
        let weightTarget = targets.first { $0.metric == .weight }
        #expect(weightTarget?.unit == .kg)
    }
}

// MARK: - Draft → WorkoutProgram Conversion

@Suite("DraftProgram to WorkoutProgram", .serialized)
@MainActor
struct DraftToWorkoutProgramTests {

    @Test func convertsBasicFields() {
        var draft = DraftProgram()
        draft.name = "Starting Strength"
        draft.programDescription = "Beginner barbell program"
        draft.programType = .strength
        draft.sourceType = .manual

        let program = draft.toWorkoutProgram()
        #expect(program.name == "Starting Strength")
        #expect(program.programDescription == "Beginner barbell program")
        #expect(program.programType == .strength)
        #expect(program.sourceType == .manual)
        #expect(program.isActive == false)
    }

    @Test func emptyDescriptionBecomesNil() {
        var draft = DraftProgram()
        draft.name = "Test"
        draft.programDescription = ""

        let program = draft.toWorkoutProgram()
        #expect(program.programDescription == nil)
    }

    @Test func convertsWeeksAndDays() {
        var draft = DraftProgram()
        draft.name = "PPL"
        var week = DraftWeek(weekNumber: 1)
        week.days = [
            DraftDay(dayOfWeek: .monday, name: "Push", dayType: .training),
            DraftDay(dayOfWeek: .tuesday, name: "Pull", dayType: .training),
            DraftDay(dayOfWeek: .wednesday, dayType: .rest),
        ]
        draft.weeks = [week]

        let program = draft.toWorkoutProgram()
        #expect(program.weeks.count == 1)
        #expect(program.weeks[0].days.count == 3)
        #expect(program.weeks[0].days[0].name == "Push")
        #expect(program.weeks[0].days[0].dayOfWeek == .monday)
        #expect(program.weeks[0].days[2].dayType == .rest)
    }

    @Test func convertsActivitiesWithTargets() {
        var activity = DraftActivity()
        activity.activityName = "Barbell Squat"
        activity.activityType = .strength
        activity.sets = 5
        activity.reps = 5
        activity.weight = 225
        activity.weightUnit = .lbs
        activity.restBetweenSets = 180

        var day = DraftDay(dayOfWeek: .monday, name: "Squat Day", dayType: .training)
        day.activities = [activity]

        var week = DraftWeek(weekNumber: 1)
        week.days = [day]

        var draft = DraftProgram()
        draft.name = "5x5"
        draft.weeks = [week]

        let program = draft.toWorkoutProgram()
        let programActivity = program.weeks[0].days[0].activities[0]
        #expect(programActivity.activityName == "Barbell Squat")
        #expect(programActivity.restBetweenSets == 180)
        #expect(programActivity.targets.count == 2) // reps + weight

        let repsTarget = programActivity.targets.first { $0.metric == .reps }
        #expect(repsTarget?.value == 5)
        #expect(repsTarget?.repeatCount == 5)

        let weightTarget = programActivity.targets.first { $0.metric == .weight }
        #expect(weightTarget?.value == 225)
        #expect(weightTarget?.unit == .lbs)
    }

    @Test func setsParentRelationships() {
        var draft = DraftProgram.defaultProgram()
        draft.name = "Test"
        let program = draft.toWorkoutProgram()

        // Week → Program
        #expect(program.weeks[0].program === program)
        // Day → Week
        #expect(program.weeks[0].days[0].week === program.weeks[0])
    }

    @Test func emptyNotesBecomesNil() {
        var day = DraftDay(dayOfWeek: .monday, dayType: .training)
        day.notes = ""
        day.name = ""

        var activity = DraftActivity()
        activity.activityName = "Test"
        activity.notes = ""
        day.activities = [activity]

        var week = DraftWeek(weekNumber: 1)
        week.days = [day]

        var draft = DraftProgram()
        draft.name = "Test"
        draft.weeks = [week]

        let program = draft.toWorkoutProgram()
        let programDay = program.weeks[0].days[0]
        #expect(programDay.notes == nil)
        #expect(programDay.name == nil)
        #expect(programDay.activities[0].notes == nil)
    }
}

// MARK: - WorkoutProgram → Draft Conversion (Round-Trip)

@Suite("WorkoutProgram to DraftProgram", .serialized)
@MainActor
struct WorkoutProgramToDraftTests {

    @Test func preservesAllFields() {
        let program = WorkoutProgram(
            name: "Starting Strength",
            programDescription: "Barbell basics",
            programType: .strength,
            sourceType: .naturalLanguage,
            sourceText: "3x5 barbell program"
        )

        let draft = DraftProgram.from(program: program)
        #expect(draft.name == "Starting Strength")
        #expect(draft.programDescription == "Barbell basics")
        #expect(draft.programType == .strength)
        #expect(draft.sourceType == .naturalLanguage)
        #expect(draft.sourceText == "3x5 barbell program")
    }

    @Test func nilDescriptionBecomesEmptyString() {
        let program = WorkoutProgram(name: "Test", programType: .strength, sourceType: .manual)

        let draft = DraftProgram.from(program: program)
        #expect(draft.programDescription == "")
    }

    @Test func customNameForDuplicate() {
        let program = WorkoutProgram(name: "My Program", programType: .strength, sourceType: .manual)

        let draft = DraftProgram.from(program: program, newName: "My Program (Copy)")
        #expect(draft.name == "My Program (Copy)")
    }

    @Test func roundTrip_basicProgram() {
        // Create a draft, convert to model, convert back — fields should match
        var original = DraftProgram()
        original.name = "Round Trip Test"
        original.programDescription = "Testing conversion"
        original.programType = .hybrid

        var activity = DraftActivity()
        activity.activityName = "Bench Press"
        activity.sets = 4
        activity.reps = 8
        activity.weight = 155
        activity.weightUnit = .lbs
        activity.restBetweenSets = 90

        var day = DraftDay(dayOfWeek: .monday, name: "Day A", dayType: .training)
        day.activities = [activity]

        var week = DraftWeek(weekNumber: 1)
        week.days = [day]
        original.weeks = [week]

        // Draft → Model → Draft
        let model = original.toWorkoutProgram()
        let roundTripped = DraftProgram.from(program: model)

        #expect(roundTripped.name == "Round Trip Test")
        #expect(roundTripped.programType == .hybrid)
        #expect(roundTripped.weeks.count == 1)
        #expect(roundTripped.weeks[0].days.count == 1)

        let rtActivity = roundTripped.weeks[0].days[0].activities[0]
        #expect(rtActivity.activityName == "Bench Press")
        #expect(rtActivity.sets == 4)
        #expect(rtActivity.reps == 8)
        #expect(rtActivity.weight == 155)
        #expect(rtActivity.weightUnit == .lbs)
        #expect(rtActivity.restBetweenSets == 90)
    }

    @Test func sortsWeeksByNumber() {
        let program = WorkoutProgram(name: "Test", programType: .strength, sourceType: .manual)
        let week3 = ProgramWeek(weekNumber: 3)
        let week1 = ProgramWeek(weekNumber: 1)
        let week2 = ProgramWeek(weekNumber: 2)
        program.weeks = [week3, week1, week2]

        let draft = DraftProgram.from(program: program)
        #expect(draft.weeks.map { $0.weekNumber } == [1, 2, 3])
    }

    @Test func sortsDaysByDayOfWeek() {
        let program = WorkoutProgram(name: "Test", programType: .strength, sourceType: .manual)
        let week = ProgramWeek(weekNumber: 1)
        week.days = [
            ProgramDay(dayOfWeek: .friday, dayType: .training),
            ProgramDay(dayOfWeek: .monday, dayType: .training),
            ProgramDay(dayOfWeek: .wednesday, dayType: .rest),
        ]
        program.weeks = [week]

        let draft = DraftProgram.from(program: program)
        let dayValues = draft.weeks[0].days.map { $0.dayOfWeek.rawValue }
        #expect(dayValues == [1, 3, 5]) // monday, wednesday, friday
    }

    @Test func sortsActivitiesByOrderIndex() {
        let program = WorkoutProgram(name: "Test", programType: .strength, sourceType: .manual)
        let week = ProgramWeek(weekNumber: 1)
        let day = ProgramDay(dayOfWeek: .monday, dayType: .training)
        day.activities = [
            ProgramActivity(activityName: "Deadlift", activityType: .strength, orderIndex: 2),
            ProgramActivity(activityName: "Squat", activityType: .strength, orderIndex: 0),
            ProgramActivity(activityName: "Bench", activityType: .strength, orderIndex: 1),
        ]
        week.days = [day]
        program.weeks = [week]

        let draft = DraftProgram.from(program: program)
        let activityNames = draft.weeks[0].days[0].activities.map { $0.activityName }
        #expect(activityNames == ["Squat", "Bench", "Deadlift"])
    }
}

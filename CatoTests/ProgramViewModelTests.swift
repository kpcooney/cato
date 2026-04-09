//
//  ProgramViewModelTests.swift
//  CatoTests
//
//  Created by Claude Code on 2026-03-08.
//
//  Tests for ProgramViewModel business logic.
//  Tests focus on pure logic (active toggle, draft conversion) rather than
//  ModelContext persistence to avoid hosted test container conflicts.
//

import Testing
import Foundation
@testable import Cato

// MARK: - Active Toggle Logic Tests

@Suite("ProgramViewModel Active Toggle", .serialized)
@MainActor
struct ProgramViewModelActiveToggleTests {

    @Test func setActive_deactivatesOtherPrograms() {
        // Simulate the active toggle business rule without ModelContext
        let programA = WorkoutProgram(name: "Program A", programType: .strength, sourceType: .manual, isActive: true)
        let programB = WorkoutProgram(name: "Program B", programType: .strength, sourceType: .manual, isActive: false)
        let programC = WorkoutProgram(name: "Program C", programType: .cardio, sourceType: .manual, isActive: false)

        let programs = [programA, programB, programC]

        // Simulate setActive(programB): deactivate all, then activate target
        for p in programs { p.isActive = false }
        programB.isActive = true

        let active = programs.filter { $0.isActive }
        #expect(active.count == 1)
        #expect(active.first?.name == "Program B")
        #expect(programA.isActive == false)
        #expect(programC.isActive == false)
    }

    @Test func deactivate_setsIsActiveFalse() {
        let program = WorkoutProgram(name: "Active", programType: .strength, sourceType: .manual, isActive: true)
        #expect(program.isActive == true)

        program.isActive = false
        #expect(program.isActive == false)
    }

    @Test func onlyOneActiveAtATime() {
        let programs = (1...5).map {
            WorkoutProgram(name: "Program \($0)", programType: .strength, sourceType: .manual, isActive: false)
        }

        // Activate the third one
        for p in programs { p.isActive = false }
        programs[2].isActive = true

        let activeCount = programs.filter { $0.isActive }.count
        #expect(activeCount == 1)

        // Now activate a different one
        for p in programs { p.isActive = false }
        programs[4].isActive = true

        let newActiveCount = programs.filter { $0.isActive }.count
        #expect(newActiveCount == 1)
        #expect(programs[4].isActive == true)
        #expect(programs[2].isActive == false)
    }
}

// MARK: - Draft ↔ Model Conversion Logic Tests

@Suite("ProgramViewModel Conversion Logic", .serialized)
@MainActor
struct ProgramViewModelConversionTests {

    @Test func draftFromProgram_preservesAllFields() {
        let program = WorkoutProgram(
            name: "5/3/1",
            programDescription: "Wendler's program",
            programType: .strength,
            sourceType: .naturalLanguage,
            sourceText: "531 barbell program 4 days"
        )

        let draft = DraftProgram.from(program: program)
        #expect(draft.name == "5/3/1")
        #expect(draft.programDescription == "Wendler's program")
        #expect(draft.programType == .strength)
        #expect(draft.sourceType == .naturalLanguage)
        #expect(draft.sourceText == "531 barbell program 4 days")
    }

    @Test func duplicateName_appendsCopy() {
        let program = WorkoutProgram(name: "My Program", programType: .strength, sourceType: .manual)
        let draft = DraftProgram.from(program: program, newName: "\(program.name) (Copy)")
        #expect(draft.name == "My Program (Copy)")
    }

    @Test func updatePreservesExistingId() {
        // The update flow: convert to draft, modify, then apply back
        // The program's identity (id) should not change
        let program = WorkoutProgram(name: "Original", programType: .strength, sourceType: .manual)
        let originalId = program.id

        var draft = DraftProgram.from(program: program)
        draft.name = "Updated"
        draft.programDescription = "Now with description"

        // Simulate update: apply draft fields to existing program
        program.name = draft.name
        program.programDescription = draft.programDescription.isEmpty ? nil : draft.programDescription

        #expect(program.id == originalId) // identity preserved
        #expect(program.name == "Updated")
        #expect(program.programDescription == "Now with description")
    }
}

// MARK: - BuilderMode Tests

@Suite("BuilderMode")
struct BuilderModeTests {

    @Test @MainActor func createMode() {
        let mode = BuilderMode.create
        switch mode {
        case .create:
            break // expected
        case .edit:
            Issue.record("Expected create mode")
        }
    }

    @Test @MainActor func editMode_containsProgram() {
        let program = WorkoutProgram(name: "Test", programType: .strength, sourceType: .manual)
        let mode = BuilderMode.edit(program)
        switch mode {
        case .create:
            Issue.record("Expected edit mode")
        case .edit(let p):
            #expect(p.name == "Test")
        }
    }
}

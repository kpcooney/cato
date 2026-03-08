//
//  ProgramViewModel.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Manages workout program CRUD operations and active program state.
//  Views in the Programs tab use this to create, edit, delete, duplicate,
//  and toggle active programs. Operates on SwiftData's ModelContext.
//

import Foundation
import SwiftData
import SwiftUI

/// Modes for the ProgramBuilderView — determines save behavior.
enum BuilderMode {
    case create
    case edit(WorkoutProgram)
}

@Observable
class ProgramViewModel {

    private var modelContext: ModelContext

    /// User-facing error message, cleared on next action.
    var errorMessage: String?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    /// Save a new program from a draft. Inserts into SwiftData.
    func saveProgram(_ draft: DraftProgram) {
        let program = draft.toWorkoutProgram()
        modelContext.insert(program)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to save program."
        }
    }

    // MARK: - Delete

    /// Permanently delete a program and all its children (cascade).
    func deleteProgram(_ program: WorkoutProgram) {
        modelContext.delete(program)
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to delete program."
        }
    }

    // MARK: - Active Toggle

    /// Set a program as active, deactivating all others.
    /// Business rule: only one program can be active at a time.
    func setActive(_ program: WorkoutProgram) {
        deactivateAll()
        program.isActive = true
        program.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to activate program."
        }
    }

    /// Deactivate a single program.
    func deactivate(_ program: WorkoutProgram) {
        program.isActive = false
        program.updatedAt = Date()
        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to deactivate program."
        }
    }

    // MARK: - Duplicate

    /// Create a copy of an existing program with " (Copy)" appended to the name.
    func duplicateProgram(_ program: WorkoutProgram) {
        let draft = DraftProgram.from(program: program, newName: "\(program.name) (Copy)")
        saveProgram(draft)
    }

    // MARK: - Update

    /// Update an existing program from a modified draft.
    /// Deletes old weeks (cascading to days/activities/targets) and rebuilds from draft.
    func updateProgram(_ program: WorkoutProgram, from draft: DraftProgram) {
        program.name = draft.name
        program.programDescription = draft.programDescription.isEmpty ? nil : draft.programDescription
        program.programType = draft.programType
        program.updatedAt = Date()

        // Delete old child objects (cascade handles days/activities/targets)
        for week in program.weeks {
            modelContext.delete(week)
        }

        // Rebuild from draft
        let newProgram = draft.toWorkoutProgram()
        program.weeks = newProgram.weeks
        for week in program.weeks {
            week.program = program
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = "Failed to update program."
        }
    }

    // MARK: - Private Helpers

    /// Deactivate all programs. Called before activating a new one.
    private func deactivateAll() {
        let descriptor = FetchDescriptor<WorkoutProgram>(
            predicate: #Predicate { $0.isActive == true }
        )
        if let activePrograms = try? modelContext.fetch(descriptor) {
            for program in activePrograms {
                program.isActive = false
            }
        }
    }
}

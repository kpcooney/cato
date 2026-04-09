//
//  ExerciseDatabaseTests.swift
//  CatoTests
//
//  Created by Claude Code on 2026-03-08.
//
//  Tests for ExerciseDatabase search, filtering, and category operations.
//  Uses a test-injected exercise array to avoid dependency on bundle JSON.
//

import Testing
import Foundation
@testable import Cato

// MARK: - Test Data

/// Small exercise set used across all tests.
/// Covers multiple categories, equipment types, and alias patterns.
private let testExercises: [Exercise] = [
    Exercise(name: "Barbell Bench Press", category: "chest", equipment: "barbell", aliases: ["bench press", "flat bench", "bb bench"]),
    Exercise(name: "Incline Barbell Bench Press", category: "chest", equipment: "barbell", aliases: ["incline bench"]),
    Exercise(name: "Dumbbell Bench Press", category: "chest", equipment: "dumbbell", aliases: ["db bench press"]),
    Exercise(name: "Push-Up", category: "chest", equipment: "bodyweight", aliases: ["pushup", "press-up"]),
    Exercise(name: "Barbell Squat", category: "legs", equipment: "barbell", aliases: ["squat", "back squat"]),
    Exercise(name: "Front Squat", category: "legs", equipment: "barbell", aliases: ["barbell front squat"]),
    Exercise(name: "Leg Press", category: "legs", equipment: "machine", aliases: ["45 degree leg press"]),
    Exercise(name: "Deadlift", category: "compound", equipment: "barbell", aliases: ["conventional deadlift"]),
    Exercise(name: "Pull-Up", category: "back", equipment: "bodyweight", aliases: ["pullup", "pull up"]),
    Exercise(name: "Barbell Row", category: "back", equipment: "barbell", aliases: ["bent over row", "bb row"]),
    Exercise(name: "Plank", category: "core", equipment: "bodyweight", aliases: ["front plank"]),
    Exercise(name: "Overhead Press", category: "shoulders", equipment: "barbell", aliases: ["ohp", "military press"]),
]

// MARK: - Search Tests

@Suite("ExerciseDatabase Search")
struct ExerciseDatabaseSearchTests {

    private let db = ExerciseDatabase(exercises: testExercises)

    @Test func emptyQuery_returnsEmpty() {
        #expect(db.search("").isEmpty)
    }

    @Test func whitespaceOnlyQuery_returnsEmpty() {
        #expect(db.search("   ").isEmpty)
    }

    @Test func exactNameMatch_returnsExercise() {
        let results = db.search("Barbell Bench Press")
        #expect(results.count >= 1)
        #expect(results[0].name == "Barbell Bench Press")
    }

    @Test func prefixMatch_returnsMatches() {
        // "Barbell" should match all exercises starting with "Barbell"
        let results = db.search("Barbell", limit: 20)
        #expect(results.count >= 3) // Bench, Squat, Row at minimum
        // All results should have names starting with "Barbell" (prefix matches first)
        for result in results.prefix(3) {
            #expect(result.name.lowercased().hasPrefix("barbell"))
        }
    }

    @Test func containsMatch_returnsMatches() {
        // "bench" appears in multiple exercise names but not always as prefix
        let results = db.search("bench", limit: 20)
        #expect(results.count >= 3) // Barbell Bench, Incline Bench, Dumbbell Bench
    }

    @Test func aliasMatch_returnsExercise() {
        // "ohp" is an alias for Overhead Press
        let results = db.search("ohp")
        #expect(results.count == 1)
        #expect(results[0].name == "Overhead Press")
    }

    @Test func caseInsensitive_matchesRegardlessOfCase() {
        let lowercase = db.search("barbell bench press")
        let uppercase = db.search("BARBELL BENCH PRESS")
        let mixed = db.search("Barbell BENCH press")
        #expect(lowercase.first?.name == "Barbell Bench Press")
        #expect(uppercase.first?.name == "Barbell Bench Press")
        #expect(mixed.first?.name == "Barbell Bench Press")
    }

    @Test func prefixPrioritizedOverContains() {
        // "Barbell Bench Press" starts with "Barbell" (prefix)
        // "Incline Barbell Bench Press" contains "Barbell" but doesn't start with it
        let results = db.search("Barbell")
        // Prefix matches should come before contains matches
        let firstNames = results.prefix(3).map { $0.name }
        #expect(firstNames.allSatisfy { $0.hasPrefix("Barbell") })
    }

    @Test func respectsLimit() {
        let results = db.search("a", limit: 2) // should match many exercises
        #expect(results.count <= 2)
    }

    @Test func noMatch_returnsEmpty() {
        #expect(db.search("zzzznotanexercise").isEmpty)
    }

    @Test func aliasMatchSearch_pullup() {
        // "pullup" (no hyphen) is an alias for "Pull-Up"
        let results = db.search("pullup")
        #expect(results.count >= 1)
        #expect(results.contains(where: { $0.name == "Pull-Up" }))
    }
}

// MARK: - Category Tests

@Suite("ExerciseDatabase Categories")
struct ExerciseDatabaseCategoryTests {

    private let db = ExerciseDatabase(exercises: testExercises)

    @Test func exercisesInCategory_returnsCorrectSubset() {
        let chest = db.exercises(in: "chest")
        #expect(chest.count == 4) // Barbell Bench, Incline, Dumbbell Bench, Push-Up
        #expect(chest.allSatisfy { $0.category == "chest" })
    }

    @Test func exercisesInCategory_caseInsensitive() {
        let legs = db.exercises(in: "LEGS")
        #expect(legs.count == 3) // Squat, Front Squat, Leg Press
    }

    @Test func exercisesInCategory_nonexistent_returnsEmpty() {
        #expect(db.exercises(in: "swimming").isEmpty)
    }

    @Test func categories_returnsAllUniqueSorted() {
        let cats = db.categories
        #expect(cats.count == 6) // back, chest, compound, core, legs, shoulders
        #expect(cats == cats.sorted()) // alphabetically sorted
    }
}

// MARK: - Initialization Tests

@Suite("ExerciseDatabase Init")
struct ExerciseDatabaseInitTests {

    @Test func emptyExercises_searchReturnsEmpty() {
        let db = ExerciseDatabase(exercises: [])
        #expect(db.search("bench").isEmpty)
        #expect(db.count == 0)
    }

    @Test func count_matchesExerciseArray() {
        let db = ExerciseDatabase(exercises: testExercises)
        #expect(db.count == testExercises.count)
    }

    @Test func bundleInit_loadsExercises() {
        // This tests the real bundle init — verifies exercises.json is loadable
        let db = ExerciseDatabase()
        #expect(db.count > 0)
    }
}

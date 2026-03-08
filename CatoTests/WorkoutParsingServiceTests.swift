//
//  WorkoutParsingServiceTests.swift
//  CatoTests
//
//  Created by Claude Code on 2026-03-08.
//
//  Tests for the WorkoutParsingServiceProtocol contract and the
//  UnavailableParsingService fallback. Foundation Models service
//  cannot be tested on iOS 18.2 — tested via manual QA on iOS 26+.
//

import Foundation
import Testing
@testable import Cato

// MARK: - Unavailable Service Tests

@Suite("UnavailableParsingService")
struct UnavailableParsingServiceTests {

    @Test("isAvailable returns false")
    func unavailableServiceReportsUnavailable() {
        let service = UnavailableParsingService()
        #expect(service.isAvailable == false)
    }

    @Test("parseProgram throws error")
    func unavailableServiceThrowsOnParse() async {
        let service = UnavailableParsingService()
        do {
            _ = try await service.parseProgram(from: "any input")
            #expect(Bool(false), "Should have thrown")
        } catch {
            let nsError = error as NSError
            #expect(nsError.domain == "WorkoutParsing")
            #expect(nsError.code == -1)
        }
    }
}

// MARK: - Factory Tests

@Suite("WorkoutParsingServiceFactory")
struct WorkoutParsingServiceFactoryTests {

    @Test("factory returns a service")
    func factoryReturnsService() {
        let service = WorkoutParsingServiceFactory.makeService()
        // On iOS 18.2 simulator, this will be UnavailableParsingService
        // On iOS 26+, this would be FoundationModelsService
        #expect(service is WorkoutParsingServiceProtocol)
    }

    @Test("factory service on iOS 18.2 is unavailable")
    func factoryServiceOnCurrentOS() {
        let service = WorkoutParsingServiceFactory.makeService()
        // Running on iOS 18.2 simulator — Foundation Models not available
        if #available(iOS 26, *) {
            // On iOS 26+, availability depends on device capabilities
        } else {
            #expect(service.isAvailable == false)
        }
    }
}

// MARK: - Protocol Contract Tests (via mock)

/// Mock service for testing protocol contract.
private class MockParsingService: WorkoutParsingServiceProtocol {
    var isAvailable: Bool = true
    var mockResult: DraftProgram?
    var mockError: Error?

    func parseProgram(from input: String) async throws -> DraftProgram {
        if let error = mockError { throw error }
        return mockResult ?? DraftProgram.defaultProgram()
    }
}

@Suite("WorkoutParsingServiceProtocol contract")
struct WorkoutParsingServiceContractTests {

    @Test("mock service reports available")
    func mockServiceAvailable() {
        let mock = MockParsingService()
        #expect(mock.isAvailable == true)
    }

    @Test("mock service can return a program")
    func mockServiceReturnsProgram() async throws {
        let mock = MockParsingService()
        var draft = DraftProgram()
        draft.name = "Test Program"
        draft.weeks = [DraftWeek.defaultWeek(number: 1)]
        mock.mockResult = draft

        let result = try await mock.parseProgram(from: "test input")
        #expect(result.name == "Test Program")
        #expect(result.weeks.count == 1)
    }

    @Test("mock service can throw an error")
    func mockServiceThrowsError() async {
        let mock = MockParsingService()
        mock.mockError = NSError(domain: "Test", code: 42, userInfo: nil)

        do {
            _ = try await mock.parseProgram(from: "test input")
            #expect(Bool(false), "Should have thrown")
        } catch {
            let nsError = error as NSError
            #expect(nsError.code == 42)
        }
    }

    @Test("unavailable mock reports false")
    func unavailableMock() {
        let mock = MockParsingService()
        mock.isAvailable = false
        #expect(mock.isAvailable == false)
    }
}

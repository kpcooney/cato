//
//  CatoApp.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI
import SwiftData

@main
struct CatoApp: App {

    @State private var authService = AuthenticationService()

    var sharedModelContainer: ModelContainer = {
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
            ProgressionEvent.self
        ])

        // Attempt CloudKit-backed storage; fall back to local-only if iCloud is unavailable
        // (e.g., simulator without iCloud sign-in, or no network).
        let cloudConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.cato.trainer")
        )

        if let container = try? ModelContainer(for: schema, configurations: [cloudConfiguration]) {
            return container
        }

        // Fallback: local SQLite store, no CloudKit sync
        let localConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [localConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authService)
        }
        .modelContainer(sharedModelContainer)
    }
}

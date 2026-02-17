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

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.cato.trainer")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environment(authService)
            } else {
                SignInView()
                    .environment(authService)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

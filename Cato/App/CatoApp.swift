//
//  CatoApp.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI
import SwiftData

@main
struct CatoApp: App {

    /// @State (not @StateObject) because AuthenticationService uses @Observable.
    /// Using @State here keeps authService alive for the entire app lifetime while
    /// still allowing SwiftUI to observe it for isAuthenticated changes.
    @State private var authService = AuthenticationService()

    /// Configures SwiftData with CloudKit sync and registers all @Model types.
    ///
    /// All 12 models must be listed here so SwiftData can build the schema and
    /// create the CloudKit record types. Missing a model here causes a runtime crash.
    ///
    /// `.private("iCloud.com.cato.trainer")` keeps all user data in their private
    /// CloudKit database — only visible to the authenticated user on their devices.
    /// This identifier must match Cato.entitlements and the CloudKit dashboard.
    ///
    /// `isStoredInMemoryOnly: false` means data persists across app launches.
    /// For unit tests, override this with a memory-only container to avoid polluting
    /// the on-disk store.
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
            // SwiftData failing to create the container is unrecoverable — the app
            // cannot function without persistent storage. This should never fire in
            // production, but fatalError surfaces schema migration bugs during development.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Auth gating: show the sign-in screen until the user authenticates.
            // AuthenticationService.isAuthenticated is set to true after a successful
            // Apple Sign-In callback. Once true, ContentView (4-tab shell) is shown.
            // Both branches receive authService via the environment so they can read
            // auth state and trigger sign-out.
            if authService.isAuthenticated {
                ContentView()
                    .environment(authService)
            } else {
                SignInView()
                    .environment(authService)
            }
        }
        // Attach the ModelContainer to the window group so every view in the hierarchy
        // can access @Environment(\.modelContext) and @Query automatically.
        .modelContainer(sharedModelContainer)
    }
}

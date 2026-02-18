//
//  ContentView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI

/// Root view shown after successful authentication. Hosts the four main tabs.
///
/// Tab order matters for usability: Today is the primary daily-use screen (tab 0),
/// Programs is for program management (tab 1), History for reviewing past workouts
/// (tab 2), and Settings for preferences (tab 3). This order is intentional —
/// users land on Today every time they open the app.
///
/// Tab tags (integers 0–3) allow programmatic navigation in the future, e.g.
/// deep-linking from a notification to the Today tab after a missed workout.
struct ContentView: View {

    /// Tracks the currently selected tab. Stored as @State so tab switches cause
    /// a re-render of the selected tab's content without rebuilding sibling tabs.
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            ProgramListView()
                .tabItem {
                    Label("Programs", systemImage: "list.bullet.clipboard")
                }
                .tag(1)

            HistoryListView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
}

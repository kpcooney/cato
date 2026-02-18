//
//  TodayView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI
import SwiftData

/// The app's home screen — the first thing users see when they open Cato.
///
/// Displays the active program's greeting and a "Start Workout" button.
/// If no program is active, a ContentUnavailableView guides the user to the
/// Programs tab to create or activate one.
///
/// In Phase 3, this view will:
/// - Determine today's scheduled day (based on dayOfWeek and last session date)
/// - Show the specific day name ("Push Day", "Lower Body", etc.)
/// - Pass the correct ProgramDay to ActiveSessionView when "Start Workout" is tapped
///
/// Currently (Phase 1–2): greeting is hardcoded ("Push Day") and Start Workout
/// is a no-op. The @Query for programs gives us the active program for display.
struct TodayView: View {

    /// @Query loads all programs from SwiftData. We derive activeProgram from this
    /// rather than filtering in the query predicate to avoid a separate query.
    /// There should only ever be one active program, so `.first` is safe.
    @Query private var programs: [WorkoutProgram]

    var activeProgram: WorkoutProgram? {
        programs.first(where: { $0.isActive })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let program = activeProgram {
                    // CatoPersona.trainingDayGreeting ensures consistent voice-line format.
                    // TODO (Phase 3): Pass the actual scheduled day name from ProgramDay.
                    Text(CatoPersona.trainingDayGreeting(dayName: "Push Day"))
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()

                    Text(program.name)
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        // TODO (Phase 3): Navigate to ActiveSessionView with today's ProgramDay.
                    } label: {
                        Text("Start Workout")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                } else {
                    // No active program — guide the user to set one up.
                    ContentUnavailableView(
                        "No Active Program",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Create or activate a program in the Programs tab to get started.")
                    )
                }
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}

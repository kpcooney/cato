//
//  HistoryListView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI
import SwiftData

/// Chronological list of all completed and abandoned workout sessions.
///
/// Sessions are sorted most-recent-first so users can review their latest
/// workout without scrolling. The `.reverse` sort on `date` is set at the
/// @Query level — SwiftData handles this in the fetch rather than in memory.
///
/// Phase 5 will expand this view with:
/// - Per-session drill-down to SessionDetailView (exercises, sets, HR, progression events)
/// - Filter controls (by program, date range)
/// - Per-activity history (all instances of a specific exercise across sessions)
/// - Session summary stats (volume, duration trend)
///
/// Currently (Phase 1–2): displays basic session metadata. Tap on a row is a no-op.
struct HistoryListView: View {

    /// Sorted most-recent-first. All sessions regardless of status (completed or abandoned)
    /// are shown so users have a complete audit trail. Abandoned sessions are visually
    /// distinguished by the absence of the checkmark badge.
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Workout History",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Complete your first workout to see it here.")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            // TODO (Phase 5): Wrap in NavigationLink to SessionDetailView.
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(session.date, style: .date)
                                        .font(.headline)

                                    Spacer()

                                    // Checkmark only for fully completed sessions.
                                    // Abandoned sessions have no badge — they're still shown
                                    // for accountability but clearly marked by absence.
                                    if session.status == .completed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }

                                // Program name is a soft reference — it may be nil if the
                                // program was deleted after the session was logged.
                                if let program = session.program {
                                    Text(program.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                HStack {
                                    // Duration: derived from startTime/endTime rather than stored,
                                    // keeping the model lean. nil endTime means abandoned mid-session.
                                    if let endTime = session.endTime {
                                        let duration = Int(endTime.timeIntervalSince(session.startTime) / 60)
                                        Text("\(duration) min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Text("\(session.completedActivities.count) exercises")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryListView()
}

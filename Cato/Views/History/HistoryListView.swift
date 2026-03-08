//
//  HistoryListView.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {

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
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(session.date, style: .date)
                                        .font(.headline)

                                    Spacer()

                                    if session.status == .completed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                }

                                if let program = session.program {
                                    Text(program.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                HStack {
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

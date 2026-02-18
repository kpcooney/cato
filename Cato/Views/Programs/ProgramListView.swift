//
//  ProgramListView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI
import SwiftData

/// Lists all of the user's workout programs with create, delete, and active-badge UI.
///
/// Phase 2 will expand this view significantly:
/// - "+" toolbar button opens a sheet with "Build Manually" / "AI Builder" choices
/// - Swipe actions: archive (soft-delete) and delete (permanent, with confirmation alert)
/// - Tap a row → ProgramDetailView
/// - Active badge wired to ProgramViewModel.setActive()
///
/// Currently (Phase 1): delete via swipe is functional. Create is a no-op.
/// @Query with no predicate returns all programs; we show all regardless of archive state
/// until archive is implemented in Phase 2.
struct ProgramListView: View {

    /// modelContext for delete operations. Injected by SwiftData from the environment.
    @Environment(\.modelContext) private var modelContext

    /// @Query automatically refreshes the list when programs are added, deleted, or updated.
    /// No sort descriptor here — Phase 2 will add sort by updatedAt or user-defined order.
    @Query private var programs: [WorkoutProgram]

    var body: some View {
        NavigationStack {
            Group {
                if programs.isEmpty {
                    ContentUnavailableView(
                        "No Programs",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Create your first workout program to get started.")
                    )
                } else {
                    List {
                        ForEach(programs) { program in
                            // TODO (Phase 2): Wrap in NavigationLink to ProgramDetailView.
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(program.name)
                                        .font(.headline)

                                    if program.isActive {
                                        Spacer()
                                        // Active badge — only one program can carry this at a time.
                                        // ProgramViewModel.setActive() enforces the single-active rule.
                                        Text("Active")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                }

                                if let description = program.programDescription {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Text(program.programType.rawValue.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deletePrograms)
                    }
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO (Phase 2): Show action sheet with "Build Manually" / "AI Builder".
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    /// Permanently deletes selected programs from the SwiftData store.
    /// SwiftData's cascade delete rules remove all associated weeks, days,
    /// activities, and targets automatically.
    ///
    /// Phase 2 will add a confirmation alert before deleting (especially important
    /// for programs that have associated session history).
    private func deletePrograms(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(programs[index])
        }
    }
}

#Preview {
    ProgramListView()
}

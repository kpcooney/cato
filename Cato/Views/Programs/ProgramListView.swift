//
//  ProgramListView.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI
import SwiftData

struct ProgramListView: View {

    @Environment(\.modelContext) private var modelContext
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
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(program.name)
                                        .font(.headline)

                                    if program.isActive {
                                        Spacer()
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
                        // Create new program action
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func deletePrograms(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(programs[index])
        }
    }
}

#Preview {
    ProgramListView()
}

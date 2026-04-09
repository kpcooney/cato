//
//  ProgramListView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Programs tab: lists all workout programs with create/edit/delete/duplicate/
//  active toggle. "+" button presents creation options (manual builder or
//  AI builder when available). Tapping a row navigates to ProgramDetailView.
//

import SwiftUI
import SwiftData

struct ProgramListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutProgram.updatedAt, order: .reverse) private var programs: [WorkoutProgram]

    @State private var viewModel: ProgramViewModel?
    @State private var showingCreateSheet = false
    @State private var showingBuilder = false
    @State private var showingNLInput = false
    @State private var programToDelete: WorkoutProgram?
    @State private var showingDeleteConfirmation = false

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
                    programList
                }
            }
            .navigationTitle("Programs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create new program")
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                createOptionsSheet
            }
            .sheet(isPresented: $showingBuilder) {
                NavigationStack {
                    ProgramBuilderView(
                        draft: DraftProgram.defaultProgram(),
                        mode: .create,
                        viewModel: ensureViewModel()
                    )
                }
            }
            .sheet(isPresented: $showingNLInput) {
                NavigationStack {
                    NaturalLanguageInputView(viewModel: ensureViewModel())
                }
            }
            .alert("Delete Program", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    if let program = programToDelete {
                        ensureViewModel().deleteProgram(program)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete \"\(programToDelete?.name ?? "")\" and all its data.")
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = ProgramViewModel(modelContext: modelContext)
                }
            }
        }
    }

    // MARK: - Program List

    private var programList: some View {
        List {
            ForEach(programs) { program in
                NavigationLink(value: program.id) {
                    ProgramRowView(program: program)
                }
                .contextMenu {
                    contextMenu(for: program)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        programToDelete = program
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationDestination(for: UUID.self) { programId in
            if let program = programs.first(where: { $0.id == programId }) {
                ProgramDetailView(program: program, viewModel: ensureViewModel())
            }
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenu(for program: WorkoutProgram) -> some View {
        if program.isActive {
            Button {
                ensureViewModel().deactivate(program)
            } label: {
                Label("Deactivate", systemImage: "star.slash")
            }
        } else {
            Button {
                ensureViewModel().setActive(program)
            } label: {
                Label("Set Active", systemImage: "star.fill")
            }
        }

        Button {
            ensureViewModel().duplicateProgram(program)
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }

        Divider()

        Button(role: .destructive) {
            programToDelete = program
            showingDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // MARK: - Create Options Sheet

    private var createOptionsSheet: some View {
        NavigationStack {
            List {
                Button {
                    showingCreateSheet = false
                    // Delay to avoid sheet dismissal conflict
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingBuilder = true
                    }
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Build Manually")
                                .font(.headline)
                            Text("Create a program step by step")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "hammer")
                    }
                }
                .accessibilityLabel("Build program manually")

                // AI Builder — conditionally available based on Foundation Models
                aiBuilderButton
            }
            .navigationTitle("New Program")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        showingCreateSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    /// AI Builder button — enabled only when Foundation Models is available.
    @ViewBuilder
    private var aiBuilderButton: some View {
        let service = WorkoutParsingServiceFactory.makeService()
        if service.isAvailable {
            Button {
                showingCreateSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingNLInput = true
                }
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Builder")
                            .font(.headline)
                        Text("Describe your program in plain text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "sparkles")
                }
            }
            .accessibilityLabel("Create program with AI builder")
        } else {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Builder")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Requires iOS 26 and Apple Intelligence")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            } icon: {
                Image(systemName: "sparkles")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("AI Builder unavailable, requires iOS 26")
        }
    }

    // MARK: - Helpers

    /// Lazily create the view model if needed, reuse if already created.
    private func ensureViewModel() -> ProgramViewModel {
        if let vm = viewModel { return vm }
        let vm = ProgramViewModel(modelContext: modelContext)
        viewModel = vm
        return vm
    }
}

#Preview {
    ProgramListView()
        .modelContainer(for: WorkoutProgram.self, inMemory: true)
}

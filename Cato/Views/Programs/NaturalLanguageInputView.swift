//
//  NaturalLanguageInputView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Text input for natural language workout description, parsed by
//  Foundation Models into a structured DraftProgram. On success,
//  navigates to ProgramBuilderView for review and editing before save.
//

import SwiftUI

struct NaturalLanguageInputView: View {
    let viewModel: ProgramViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var parsedDraft: DraftProgram?
    @State private var showingBuilder = false

    private let parsingService = WorkoutParsingServiceFactory.makeService()

    var body: some View {
        Form {
            inputSection
            if let error = errorMessage {
                errorSection(error)
            }
            tipsSection
        }
        .navigationTitle("AI Builder")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Generate") { generate() }
                    .fontWeight(.semibold)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
        }
        .navigationDestination(isPresented: $showingBuilder) {
            if let draft = parsedDraft {
                ProgramBuilderView(
                    draft: draft,
                    mode: .create,
                    viewModel: viewModel
                )
            }
        }
        .disabled(isLoading)
        .overlay {
            if isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        Section {
            TextEditor(text: $inputText)
                .frame(minHeight: 150)
                .accessibilityLabel("Workout program description")
        } header: {
            Text("Describe Your Program")
        } footer: {
            Text("Describe your workout program in plain text. Include exercises, sets, reps, and schedule.")
        }
    }

    // MARK: - Error Section

    private func errorSection(_ error: String) -> some View {
        Section {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        Section("Examples") {
            Group {
                Text("\"5x5 program: squat, bench, row on Monday/Wednesday/Friday\"")
                Text("\"Push pull legs split, 4 sets of 8-12 reps, rest days on weekends\"")
                Text("\"Upper lower split, 3x10 for accessories, 5x5 for compounds\"")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("Parsing your program...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Generate

    private func generate() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        errorMessage = nil
        isLoading = true

        Task {
            do {
                let draft = try await parsingService.parseProgram(from: trimmed)
                parsedDraft = draft
                isLoading = false
                showingBuilder = true
            } catch {
                isLoading = false
                errorMessage = CatoPersona.serverError()
            }
        }
    }
}

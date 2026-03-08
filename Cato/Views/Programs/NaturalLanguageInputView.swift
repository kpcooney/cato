//
//  NaturalLanguageInputView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Text input for natural language workout description, parsed by
//  Foundation Models into a structured program.
//  Stub — full implementation in Commit 8.
//

import SwiftUI

struct NaturalLanguageInputView: View {
    let viewModel: ProgramViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("AI Builder — Coming Soon")
            .navigationTitle("AI Builder")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
    }
}

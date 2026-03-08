//
//  ProgramBuilderView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Manual program creation form with navigation-based drill-down.
//  Stub — full implementation in Commit 5.
//

import SwiftUI

struct ProgramBuilderView: View {
    @State var draft: DraftProgram
    let mode: BuilderMode
    let viewModel: ProgramViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text("Program Builder — Coming Soon")
            .navigationTitle(mode.isCreate ? "New Program" : "Edit Program")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
    }
}

// MARK: - BuilderMode Helpers

extension BuilderMode {
    var isCreate: Bool {
        switch self {
        case .create: return true
        case .edit: return false
        }
    }
}

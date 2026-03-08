//
//  ProgramDetailView.swift
//  Cato
//
//  Created by Claude Code on 2026-03-08.
//
//  Read-only view of a workout program's structure with edit capability.
//  Stub — full implementation in Commit 6.
//

import SwiftUI

struct ProgramDetailView: View {
    let program: WorkoutProgram
    let viewModel: ProgramViewModel

    var body: some View {
        Text(program.name)
            .navigationTitle(program.name)
    }
}

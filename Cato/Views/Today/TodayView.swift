//
//  TodayView.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI
import SwiftData

struct TodayView: View {

    @Query private var programs: [WorkoutProgram]

    var activeProgram: WorkoutProgram? {
        programs.first(where: { $0.isActive })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let program = activeProgram {
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
                        // Start workout action
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

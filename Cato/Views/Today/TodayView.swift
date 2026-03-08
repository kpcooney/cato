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
                    activeProgramContent(program)
                } else {
                    ContentUnavailableView(
                        "No Active Program",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text(CatoPersona.noProgramActive())
                    )
                }
            }
            .navigationTitle("Today")
        }
    }

    // MARK: - Active Program Content

    private func activeProgramContent(_ program: WorkoutProgram) -> some View {
        VStack(spacing: 20) {
            // Greeting based on today's day type
            Text(greetingText(for: program))
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()

            Text(program.name)
                .font(.headline)
                .foregroundStyle(.secondary)

            // Show today's day info if available
            if let todayDay = todaysProgramDay(for: program) {
                todayDayCard(todayDay)
            }

            Spacer()

            if todaysProgramDay(for: program)?.dayType == .training {
                Button {
                    // Start workout action — Phase 3
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
                .accessibilityLabel("Start today's workout")
            }
        }
    }

    // MARK: - Today's Day

    /// Find the ProgramDay matching today's day of week in the first week.
    private func todaysProgramDay(for program: WorkoutProgram) -> ProgramDay? {
        guard let firstWeek = program.weeks.min(by: { $0.weekNumber < $1.weekNumber }) else {
            return nil
        }
        let today = currentDayOfWeek()
        return firstWeek.days.first { $0.dayOfWeek == today }
    }

    /// Map the current calendar day to our DayOfWeek enum.
    private func currentDayOfWeek() -> DayOfWeek {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar.weekday: 1=Sunday, 2=Monday, ... 7=Saturday
        // DayOfWeek: 1=Monday, 2=Tuesday, ... 7=Sunday
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }

    /// Generate the greeting based on today's day type.
    private func greetingText(for program: WorkoutProgram) -> String {
        guard let today = todaysProgramDay(for: program) else {
            return CatoPersona.trainingDayGreeting(dayName: program.name)
        }

        switch today.dayType {
        case .training:
            let dayName = today.name ?? today.dayOfWeek.displayName
            return CatoPersona.trainingDayGreeting(dayName: dayName)
        case .rest:
            return CatoPersona.restDayGreeting()
        case .activeRecovery:
            return CatoPersona.restDayGreeting()
        }
    }

    // MARK: - Today's Day Card

    private func todayDayCard(_ day: ProgramDay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day.dayOfWeek.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if let name = day.name, !name.isEmpty {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(day.dayType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(day.dayType == .training ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                    .foregroundStyle(day.dayType == .training ? .blue : .gray)
                    .cornerRadius(6)
            }

            if day.dayType == .training && !day.activities.isEmpty {
                let sorted = day.activities.sorted { $0.orderIndex < $1.orderIndex }
                ForEach(sorted, id: \.id) { activity in
                    HStack {
                        Text(activity.activityName)
                            .font(.caption)
                        Spacer()
                        let repsTarget = activity.targets.first { $0.metric == .reps }
                        let weightTarget = activity.targets.first { $0.metric == .weight }
                        let sets = repsTarget?.repeatCount ?? 0
                        let reps = Int(repsTarget?.value ?? 0)
                        if let wt = weightTarget, wt.value > 0 {
                            Text("\(sets)x\(reps) @ \(Int(wt.value)) \(wt.unit.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("\(sets)x\(reps)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    TodayView()
}

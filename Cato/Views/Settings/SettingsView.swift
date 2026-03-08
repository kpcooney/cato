//
//  SettingsView.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("weightUnit") private var weightUnit = "lbs"
    @AppStorage("voiceEnabled") private var voiceEnabled = true
    @AppStorage("speechRate") private var speechRate = 0.5

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("Pounds (lbs)").tag("lbs")
                        Text("Kilograms (kg)").tag("kg")
                    }
                }

                Section("Voice") {
                    Toggle("Voice Coaching", isOn: $voiceEnabled)

                    if voiceEnabled {
                        VStack(alignment: .leading) {
                            Text("Speech Rate")
                                .font(.subheadline)

                            Slider(value: $speechRate, in: 0.3...0.7) {
                                Text("Speech Rate")
                            } minimumValueLabel: {
                                Text("Slow")
                                    .font(.caption)
                            } maximumValueLabel: {
                                Text("Fast")
                                    .font(.caption)
                            }
                        }
                    }
                }

                Section("HealthKit") {
                    Button("Request HealthKit Permissions") {
                        // Request HealthKit authorization
                    }
                }

                Section("Account") {
                    Button("Sign Out") {
                        // Sign out action
                    }
                    .foregroundStyle(.red)
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

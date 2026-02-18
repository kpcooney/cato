//
//  SettingsView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI

/// User preferences and account management screen.
///
/// Preferences here are stored with @AppStorage (UserDefaults) so they persist
/// across sessions without requiring SwiftData or CloudKit. They are per-device
/// by design — a user might prefer lbs on their phone and kg on a friend's device.
///
/// The full settings surface is built out in Phase 6. This Phase 1 stub establishes
/// the key settings that other parts of the app read (weightUnit, voiceEnabled, speechRate)
/// so they have defaults before the UI is wired up fully.
///
/// Key @AppStorage keys — must match where they're read elsewhere:
///   "weightUnit"    → read by ProgramBuilderView and WeightRounding helpers
///   "voiceEnabled"  → read by CatoSpeechService to skip TTS entirely
///   "speechRate"    → read by CatoSpeechService when constructing AVSpeechUtterance
struct SettingsView: View {

    /// Weight unit preference. Affects how targets are displayed and how new
    /// programs default their ActivityTarget.unit during creation.
    @AppStorage("weightUnit") private var weightUnit = "lbs"

    /// When false, Cato neither speaks nor listens during sessions. This is a
    /// first-class "voice-off" experience — rest timers show visual countdowns
    /// with optional haptics instead of audio cues.
    @AppStorage("voiceEnabled") private var voiceEnabled = true

    /// AVSpeechSynthesizer rate, clamped to 0.3–0.7 (Apple's normal range is 0–1,
    /// but values outside this window sound unnatural for coaching cues). Default 0.5.
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
                    // Toggling off hides the rate slider — no point adjusting speed
                    // of speech the user will never hear.
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
                    // TODO (Phase 5): Wire to HealthKitService.requestAuthorization().
                    // Authorization is required before any HR or calorie data can be read.
                    // If already authorized, this button could show a checkmark instead.
                    Button("Request HealthKit Permissions") {
                        // Request HealthKit authorization
                    }
                }

                Section("Account") {
                    // TODO (Phase 6): Wire to AuthenticationService.signOut().
                    // Sign out should also clear any cached user state and route back to SignInView.
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

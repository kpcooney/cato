//
//  SignInView.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import SwiftUI
import AuthenticationServices

/// Shown before authentication. Handles Apple Sign-In and routes to ContentView on success.
///
/// Cato uses Apple Sign-In exclusively — no email/password, no third-party OAuth.
/// This keeps auth simple and trustworthy: users see the Apple button they recognize,
/// and Cato never handles credentials directly.
///
/// The `colorScheme` environment value drives the button style so the Apple button
/// always has sufficient contrast: white button on dark backgrounds, black on light.
///
/// CloudKit sync becomes available as soon as iCloud sign-in is confirmed — the
/// CloudKit container uses the Apple ID identity established here.
struct SignInView: View {

    @Environment(\.colorScheme) var colorScheme

    /// AuthenticationService is injected from CatoApp — it persists across the
    /// auth/content view boundary via the environment.
    @Environment(AuthenticationService.self) private var authService

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App identity block — name, tagline, slogan. No images or icons in v1.
            VStack(spacing: 16) {
                Text("Cato")
                    .font(.system(size: 48, weight: .bold))

                Text("Your AI Personal Trainer")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("Skilled. Wise. Relentless.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Apple provides the SignInWithAppleButton component — we must use it
            // exactly as-is per App Store guidelines. We only configure style and scopes.
            SignInWithAppleButton(
                onRequest: { request in
                    // Request name and email so we can personalize the experience
                    // if the user chooses to share them. Neither is required for auth.
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAuthorization(authorization)
                    case .failure(let error):
                        // Sign-in errors (user cancelled, network issue) are non-fatal.
                        // The button stays on screen and the user can retry.
                        print("Sign in failed: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
            .padding(.horizontal, 40)

            Text("Sign in to sync your workouts across devices")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }

    /// Processes a successful Apple authorization response.
    ///
    /// In Phase 6 (polish), this will:
    /// 1. Verify the identityToken with Apple's servers to prevent replay attacks
    /// 2. Store the userIdentifier in Keychain for credential state checks on relaunch
    /// 3. Populate any user-facing name/email fields from the credential (only available on first sign-in)
    ///
    /// For now, we trust the local authorization result and set isAuthenticated directly.
    /// This is acceptable for development — do not ship without proper token verification.
    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        // TODO (Phase 6): Verify appleIDCredential.identityToken with Apple's API.
        // TODO (Phase 6): Store appleIDCredential.user in Keychain.
        // Suppress unused variable warning — credential will be used in Phase 6.
        _ = appleIDCredential

        authService.isAuthenticated = true
    }
}

#Preview {
    SignInView()
}

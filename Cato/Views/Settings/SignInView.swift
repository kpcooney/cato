//
//  SignInView.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(AuthenticationService.self) private var authService

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

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

            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        handleAuthorization(authorization)
                    case .failure(let error):
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

    private func handleAuthorization(_ authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        // In a real implementation, we would:
        // 1. Verify the identity token with Apple
        // 2. Store user credentials securely
        // 3. Update authentication state

        authService.isAuthenticated = true
    }
}

#Preview {
    SignInView()
}

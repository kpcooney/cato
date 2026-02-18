//
//  AuthenticationService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import AuthenticationServices

protocol AuthenticationServiceProtocol {
    var isAuthenticated: Bool { get }
    func signInWithApple() async throws -> String
    func signOut()
}

/// Manages Apple Sign-In state and is injected into the environment from CatoApp.
///
/// @Observable is used instead of ObservableObject so that views automatically
/// react to isAuthenticated changes without needing @Published. The root view
/// (CatoApp.body) switches between SignInView and ContentView based on this flag.
///
/// Note: The actual credential verification (step 1) and secure storage (step 2)
/// are not yet implemented — isAuthenticated is set to true optimistically after
/// the Apple authorization callback succeeds. A production implementation would
/// verify the identity token server-side before granting access.
@Observable
class AuthenticationService: NSObject, AuthenticationServiceProtocol {

    var isAuthenticated: Bool = false

    /// Stored between the onRequest and onCompletion callbacks in the sign-in flow.
    /// The nonce ties the authorization request to the response, preventing replay attacks.
    private var currentNonce: String?

    func signInWithApple() async throws -> String {
        // Not yet wired — sign-in is handled directly by SignInView's
        // SignInWithAppleButton callbacks, which call handleAuthorization().
        return ""
    }

    func signOut() {
        isAuthenticated = false
        // TODO: Clear Keychain-stored credentials in Phase 6 (Polish).
    }

    /// Generates a cryptographically random nonce for the Sign In with Apple request.
    /// The nonce is sent in the authorization request and expected back in the JWT,
    /// ensuring the credential was issued for this specific request.
    func generateNonce() -> String {
        return randomNonceString()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        // Map each random byte to a URL-safe character to produce a readable nonce string.
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
}

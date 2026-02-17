//
//  AuthenticationService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import AuthenticationServices

protocol AuthenticationServiceProtocol {
    var isAuthenticated: Bool { get }
    func signInWithApple() async throws -> String
    func signOut()
}

@Observable
class AuthenticationService: NSObject, AuthenticationServiceProtocol {

    var isAuthenticated: Bool = false
    private var currentNonce: String?

    func signInWithApple() async throws -> String {
        // Stub: Implement Apple Sign-In flow
        // This will be implemented in Phase 1
        return ""
    }

    func signOut() {
        isAuthenticated = false
        // Clear any stored credentials
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
}

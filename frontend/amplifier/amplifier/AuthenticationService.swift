//
//  AuthenticationService.swift
//  amplifier
//
//  Wraps Auth0 Web Auth (Universal Login) and Keychain credential storage.
//  Reads ClientId/Domain from Auth0.plist automatically.
//

import Auth0
import Combine
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    init() {
        // A stored refresh token means the user can be signed in silently.
        isAuthenticated = credentialsManager.canRenew()
    }

    /// Opens Auth0 Universal Login in a system browser sheet. All sign-in
    /// options (Apple, Google, email) are presented on the hosted page.
    func login() async {
        do {
            let credentials = try await Auth0
                .webAuth()
                .scope("openid profile email offline_access")
                .start()
            try credentialsManager.store(credentials: credentials)
            withAnimation { isAuthenticated = true }
        } catch WebAuthError.userCancelled {
            // User dismissed the login sheet — nothing to do.
        } catch {
            print("Login failed: \(error)")
        }
    }

    func logout() async {
        do {
            try await Auth0.webAuth().logout()
        } catch {
            print("Logout failed: \(error)")
        }
        try? credentialsManager.clear()
        withAnimation { isAuthenticated = false }
    }

    /// Decoded profile claims from the stored ID token (name, email, picture…).
    var user: UserProfile? { try? credentialsManager.userProfile() }

    /// Valid access token for calling the Amplifier API; auto-renews if expired.
    func accessToken() async throws -> String {
        try await credentialsManager.credentials().accessToken
    }
}

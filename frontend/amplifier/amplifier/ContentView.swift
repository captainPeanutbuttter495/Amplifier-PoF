//
//  ContentView.swift
//  amplifier
//
//  Created by Jeremiah Cabahug on 8/26/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthenticationService

    var body: some View {
        if auth.isAuthenticated {
            RootTabView {
                Task { await auth.logout() }
            }
        } else {
            SignInView {
                Task { await auth.login() }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
}

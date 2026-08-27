//
//  amplifierApp.swift
//  amplifier
//
//  Created by Jeremiah Cabahug on 8/26/26.
//

import SwiftUI

@main
struct amplifierApp: App {
    @StateObject private var auth = AuthenticationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}

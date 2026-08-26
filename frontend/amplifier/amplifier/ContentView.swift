//
//  ContentView.swift
//  amplifier
//
//  Created by Jeremiah Cabahug on 8/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            RootTabView {
                withAnimation { isSignedIn = false }
            }
        } else {
            SignInView {
                withAnimation { isSignedIn = true }
            }
        }
    }
}

#Preview {
    ContentView()
}

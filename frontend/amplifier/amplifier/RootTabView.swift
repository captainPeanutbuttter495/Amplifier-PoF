//
//  RootTabView.swift
//  amplifier
//
//  Native iOS 26 tab bar — Liquid Glass by default — replacing the
//  custom blurred tab bar in the design.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                }
            }
            Tab("Rewards", systemImage: "gift") {
                PlaceholderScreen(title: "Rewards")
            }
            Tab("Profile", systemImage: "person.crop.circle") {
                PlaceholderScreen(title: "Profile")
            }
        }
        .tint(VIP.cyan700)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

private struct PlaceholderScreen: View {
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(VIP.onyx)
            Text("Coming soon")
                .font(.system(size: 16))
                .foregroundStyle(VIP.onyx.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VIP.parchment)
    }
}

#Preview {
    RootTabView()
}

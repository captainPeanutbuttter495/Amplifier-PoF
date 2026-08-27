//
//  RootTabView.swift
//  amplifier
//
//  Native iOS 26 tab bar — Liquid Glass by default — replacing the
//  custom blurred tab bar in the design.
//

import SwiftUI

struct RootTabView: View {
    var onSignOut: () -> Void = {}

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    HomeView()
                }
            }
            Tab("Rewards", systemImage: "gift") {
                RewardsView()
            }
            Tab("Profile", systemImage: "person.crop.circle") {
                ProfileView(onSignOut: onSignOut)
            }
        }
        .tint(VIP.cyan700)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}


#Preview {
    RootTabView()
}

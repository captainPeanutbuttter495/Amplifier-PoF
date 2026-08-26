//
//  ProfileView.swift
//  amplifier
//
//  Implements "Amplifier Profile.dc.html".
//

import SwiftUI

private struct HistoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let delta: Int?          // nil renders as "0" (rejected — no points)
    let subtitleInk: Color

    init(_ title: String, _ subtitle: String, _ delta: Int?, subtitleInk: Color = VIP.onyx.opacity(0.5)) {
        self.title = title
        self.subtitle = subtitle
        self.delta = delta
        self.subtitleInk = subtitleInk
    }

    static let demo: [HistoryEntry] = [
        HistoryEntry("Redeemed: Challenge Kickoff Tee", "Aug 20", -400),
        HistoryEntry("Share the Challenge Kickoff Post", "Aug 19 · Verified", 150),
        HistoryEntry("Attend the Regional Hub Mixer", "Aug 18 · Rejected — resubmit available", nil, subtitleInk: VIP.rejectedInk),
        HistoryEntry("Refer a Challenge Participant", "Aug 17 · Verified", 300),
        HistoryEntry("Host a Dinero Dares Watch Party", "Aug 15 · Verified", 450),
        HistoryEntry("Attend the Kickoff Livestream", "Aug 14 · Verified", 250),
        HistoryEntry("Share the Gallery Reveal on TikTok", "Aug 13 · Verified", 240),
        HistoryEntry("Share the Regional Hubs Announcement", "Aug 12 · Verified", 150),
        HistoryEntry("Welcome Bonus", "Aug 10 · Joined Amplifier", 100),
    ]
}

struct ProfileView: View {
    var onSignOut: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .tracking(-0.34)
                    .foregroundStyle(VIP.onyx)
                    .padding(.bottom, 4)

                identityCard

                Text("History")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(VIP.onyx.opacity(0.55))
                    .padding(.top, 8)

                historyCard

                Button(action: onSignOut) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(VIP.rejectedInk)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(VIP.onyx.opacity(0.15), lineWidth: 1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Text("Signed in with Auth0")
                    .font(.system(size: 12))
                    .foregroundStyle(VIP.onyx.opacity(0.45))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(VIP.parchment)
    }

    private var identityCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Text("JA")
                    .font(.system(size: 20, weight: .semibold))
                    .kerning(0.4)
                    .foregroundStyle(VIP.parchment)
                    .frame(width: 56, height: 56)
                    .background(VIP.jet)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text("John Appleseed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(VIP.onyx)
                    Text("Member since Aug 2026")
                        .font(.system(size: 13))
                        .foregroundStyle(VIP.onyx.opacity(0.55))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(VIP.cyan600)
                    Text("Connector")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(VIP.cyan700)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(VIP.cyan300.opacity(0.14))
                .overlay { Capsule().strokeBorder(VIP.cyan600.opacity(0.25), lineWidth: 1) }
                .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                statBlock(value: "1,240", label: "Amplifier Score")
                statBlock(value: "1,640", label: "Lifetime Points")
            }
        }
        .padding(20)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(VIP.cyan600)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(VIP.onyx.opacity(0.55))
        }
        .padding(.leading, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            Rectangle().fill(VIP.cyan300).frame(width: 1)
        }
    }

    private var historyCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(HistoryEntry.demo.enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.title)
                            .font(.system(size: 14.5, weight: .semibold))
                            .foregroundStyle(VIP.onyx)
                        Text(entry.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(entry.subtitleInk)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(deltaText(entry.delta))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(deltaInk(entry.delta))
                }
                .padding(.vertical, 13)

                if index < HistoryEntry.demo.count - 1 {
                    Divider().overlay(VIP.onyx.opacity(0.1))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func deltaText(_ delta: Int?) -> String {
        guard let delta else { return "0" }
        return delta > 0 ? "+\(delta.formatted())" : "−\(abs(delta).formatted())"
    }

    private func deltaInk(_ delta: Int?) -> Color {
        guard let delta else { return VIP.onyx.opacity(0.35) }
        return delta > 0 ? VIP.cyan700 : VIP.onyx.opacity(0.55)
    }
}

#Preview {
    ProfileView()
}

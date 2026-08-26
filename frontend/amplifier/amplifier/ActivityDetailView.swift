//
//  ActivityDetailView.swift
//  amplifier
//
//  Implements "Amplifier Activity Detail.dc.html". Status-driven: the banner
//  and bottom CTA change with the activity's verification state.
//

import SwiftUI

struct ActivityDetailView: View {
    let activity: Activity

    @State private var copied = false
    @State private var resetCopied: Task<Void, Never>?

    private let trackedLink = "amp.ghsi-eih.org/k/u2481-kickoff"

    private var isVerified: Bool { activity.status == .verified }
    private var isRejected: Bool { activity.status == .rejected }
    private var isWaiting: Bool {
        activity.status == .submitted || activity.status == .pendingVerification
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                headerCard
                statusBanner
                instructionsSection
                    .padding(.top, 8)
                trackedLinkSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
        }
        .background(VIP.parchment)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { bottomBar }
    }

    // MARK: Header card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: activity.symbol)
                    .font(.system(size: 21, weight: .medium))
                    .foregroundStyle(activity.iconInk)
                    .frame(width: 48, height: 48)
                    .background(activity.iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(activity.name)
                    .font(.system(size: 22, weight: .bold))
                    .tracking(-0.22)
                    .foregroundStyle(VIP.onyx)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                // Points pill
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(activity.pts)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                    Text("pts")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(VIP.cyan700)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(VIP.cyan300.opacity(0.14))
                .overlay { Capsule().strokeBorder(VIP.cyan600.opacity(0.25), lineWidth: 1) }
                .clipShape(Capsule())

                // Tracked Link pill
                HStack(spacing: 5) {
                    Image(systemName: "link")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Tracked Link")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(VIP.jet)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(VIP.sky300.opacity(0.5))
                .clipShape(Capsule())

                // Status pill
                Text(activity.status.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(activity.status.badgeInk)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(activity.status.badgeBackground)
                    .clipShape(Capsule())
            }

            Text("The National Challenge kickoff is live. Share your tracked link on Instagram so your friends, classmates, and community can see what the Challenge is about — every click through your link counts toward your score.")
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(VIP.onyx.opacity(0.65))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: Status banner

    @ViewBuilder
    private var statusBanner: some View {
        if isRejected {
            banner(
                symbol: "exclamationmark.circle", ink: VIP.rejectedInk,
                background: VIP.orange400.opacity(0.08), border: VIP.orange400.opacity(0.35),
                lead: "Submission rejected.",
                text: " The link you shared wasn't your tracked link, so your clicks couldn't be counted. Share the link below and resubmit."
            )
        } else if isVerified {
            banner(
                symbol: "checkmark", ink: VIP.cyan700,
                background: VIP.cyan300.opacity(0.14), border: VIP.cyan600.opacity(0.3),
                lead: "Verified.",
                text: " Your link was clicked and the activity is complete — \(activity.pts) pts have been added to your Amplifier Score."
            )
        } else if isWaiting {
            banner(
                symbol: "clock", ink: VIP.pendingInk,
                background: VIP.logoYellow.opacity(0.22), border: VIP.logoYellow.opacity(0.6),
                lead: activity.status == .submitted ? "Submitted." : "Pending verification.",
                text: " We're confirming your share. Points are awarded once verification completes — usually within a day."
            )
        }
    }

    private func banner(symbol: String, ink: Color, background: Color, border: Color, lead: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ink)
                .padding(.top, 1)
            Text("\(Text(lead).bold().foregroundStyle(ink))\(Text(text).foregroundStyle(VIP.onyx))")
                .font(.system(size: 13.5))
                .lineSpacing(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .overlay {
            RoundedRectangle(cornerRadius: 14).strokeBorder(border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: Instructions

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Instructions")
            VStack(spacing: 0) {
                instructionRow(1, "Copy your tracked link below — it's unique to you and this activity.")
                Divider().overlay(VIP.onyx.opacity(0.1))
                instructionRow(2, "Post it on Instagram — in your story, bio, or a post caption.")
                Divider().overlay(VIP.onyx.opacity(0.1))
                instructionRow(3, "That's it — clicks are recorded automatically and points land after verification. No screenshots needed.")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func instructionRow(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(VIP.cyan700)
                .frame(width: 22, height: 22)
                .background(VIP.cyan300.opacity(0.18))
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 14.5))
                .lineSpacing(4)
                .foregroundStyle(VIP.onyx.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
    }

    // MARK: Tracked link

    private var trackedLinkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Your Tracked Link")
            Button {
                UIPasteboard.general.string = "https://\(trackedLink)"
                copied = true
                resetCopied?.cancel()
                resetCopied = Task {
                    try? await Task.sleep(for: .seconds(1.8))
                    if !Task.isCancelled { copied = false }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(trackedLink)
                        .font(.system(size: 13.5, design: .monospaced))
                        .foregroundStyle(VIP.cyan700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if copied {
                        Text("Copied")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VIP.cyan700)
                    }
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 15))
                        .foregroundStyle(VIP.onyx.opacity(0.45))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(minHeight: 48)
                .background(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(VIP.onyx.opacity(0.55))
    }

    // MARK: Bottom CTA

    @ViewBuilder
    private var bottomBar: some View {
        Group {
            if isVerified {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text("\(activity.pts) pts Earned")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(VIP.cyan700)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(VIP.cyan300.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else if isWaiting {
                Text("Awaiting Verification")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(VIP.onyx.opacity(0.5))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(VIP.onyx.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ShareLink(item: URL(string: "https://\(trackedLink)")!) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        Text(isRejected ? "Resubmit — Share Your Link" : "Share Your Link")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(VIP.cta)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

#Preview("Not Started") {
    NavigationStack {
        ActivityDetailView(activity: Activity.demo[2])
    }
}

#Preview("Verified") {
    NavigationStack {
        ActivityDetailView(activity: Activity.demo[0])
    }
}

#Preview("Rejected") {
    NavigationStack {
        ActivityDetailView(activity: Activity.demo[4])
    }
}

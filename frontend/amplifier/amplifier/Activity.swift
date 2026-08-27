//
//  Activity.swift
//  amplifier
//
//  Demo data model for the Home screen, ported from the DCLogic block in
//  "Amplifier Home.dc.html".
//

import SwiftUI

enum ActivityStatus: String, CaseIterable {
    case verified = "Verified"
    case pendingVerification = "Pending Verification"
    case notStarted = "Not Started"
    case submitted = "Submitted"
    case rejected = "Rejected"

    var label: String {
        self == .rejected ? "Rejected — Resubmit" : rawValue
    }

    var group: ActivityFilter {
        switch self {
        case .verified: .done
        case .pendingVerification, .submitted: .inReview
        case .notStarted, .rejected: .toDo
        }
    }

    var badgeBackground: Color {
        switch self {
        case .verified: VIP.cyan600.opacity(0.12)
        case .pendingVerification: VIP.logoYellow.opacity(0.28)
        case .notStarted: VIP.onyx.opacity(0.06)
        case .submitted: VIP.sky300.opacity(0.5)
        case .rejected: VIP.orange400.opacity(0.1)
        }
    }

    var badgeInk: Color {
        switch self {
        case .verified: VIP.cyan700
        case .pendingVerification: VIP.pendingInk
        case .notStarted: VIP.onyx.opacity(0.55)
        case .submitted: VIP.jet
        case .rejected: VIP.rejectedInk
        }
    }

    var badgeSymbol: String {
        switch self {
        case .verified: "checkmark"
        case .pendingVerification: "clock"
        case .notStarted: "circle"
        case .submitted: "arrow.up"
        case .rejected: "xmark"
        }
    }

    var cardBorder: Color {
        self == .rejected ? VIP.orange400.opacity(0.35) : VIP.onyx.opacity(0.10)
    }
}

enum ActivityFilter: String, CaseIterable {
    case all = "All"
    case toDo = "To Do"
    case inReview = "In Review"
    case done = "Done"
}

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let desc: String
    let pts: Int
    let status: ActivityStatus
    let symbol: String
    let iconBackground: Color
    let iconInk: Color

    static let demo: [Activity] = [
        Activity(
            name: "Share the Challenge Kickoff Post",
            desc: "Share your tracked link to the National Challenge kickoff announcement on Instagram.",
            pts: 150, status: .verified,
            symbol: "square.and.arrow.up",
            iconBackground: VIP.cyan300.opacity(0.14), iconInk: VIP.cyan600
        ),
        Activity(
            name: "Refer a Challenge Participant",
            desc: "Invite a friend with your referral link. Points land when they register for the Challenge.",
            pts: 300, status: .pendingVerification,
            symbol: "person.badge.plus",
            iconBackground: VIP.sky300.opacity(0.45), iconInk: VIP.jet
        ),
        Activity(
            name: "Post Your Build on TikTok",
            desc: "Show what your team is making for the Challenge and submit the post URL as evidence.",
            pts: 200, status: .notStarted,
            symbol: "video",
            iconBackground: VIP.wisteria400.opacity(0.2), iconInk: VIP.wisteriaInk
        ),
        Activity(
            name: "Share the Mentor Sign-Up Link",
            desc: "Post your tracked mentor recruitment link on LinkedIn to reach industry contacts.",
            pts: 100, status: .submitted,
            symbol: "link",
            iconBackground: VIP.sky300.opacity(0.45), iconInk: VIP.jet
        ),
        Activity(
            name: "Attend the Regional Hub Mixer",
            desc: "Check in at the event table. Your photo evidence was unreadable — resubmit to earn points.",
            pts: 250, status: .rejected,
            symbol: "calendar",
            iconBackground: VIP.orange400.opacity(0.1), iconInk: VIP.rejectedInk
        ),
    ]
}

// Tier ladder from the design's demo logic
enum Tier {
    static let ladder: [(name: String, threshold: Int)] = [
        ("Advocate", 0), ("Connector", 750), ("Champion", 2000), ("Amplifier", 4000)
    ]

    struct Progress {
        let tierName: String
        let fraction: Double
        let progressLabel: String
        let nextTierLabel: String
    }

    static func progress(for score: Int) -> Progress {
        var index = 0
        for (i, tier) in ladder.enumerated() where score >= tier.threshold { index = i }
        let current = ladder[index]
        guard index + 1 < ladder.count else {
            return Progress(
                tierName: current.name, fraction: 1,
                progressLabel: "Top tier reached", nextTierLabel: "Amplifier"
            )
        }
        let next = ladder[index + 1]
        let span = Double(next.threshold - current.threshold)
        return Progress(
            tierName: current.name,
            fraction: Double(score - current.threshold) / span,
            progressLabel: "\((next.threshold - score).formatted()) pts to \(next.name)",
            nextTierLabel: "Next: \(next.name)"
        )
    }
}

//
//  HomeView.swift
//  amplifier
//
//  Implements "Amplifier Home.dc.html". The custom blurred tab bar from the
//  design is replaced by the native Liquid Glass TabView (see RootTabView).
//

import SwiftUI

enum SortOrder {
    case none, descending, ascending

    var label: String {
        switch self {
        case .none: "Sort"
        case .descending: "Points, high first"
        case .ascending: "Points, low first"
        }
    }

    var symbol: String {
        switch self {
        case .none: "arrow.up.arrow.down"
        case .descending: "arrow.down"
        case .ascending: "arrow.up"
        }
    }

    var next: SortOrder {
        switch self {
        case .none: .descending
        case .descending: .ascending
        case .ascending: .none
        }
    }
}

struct HomeView: View {
    let score = 1240

    @State private var filter: ActivityFilter = .all
    @State private var sort: SortOrder = .none

    private var activities: [Activity] {
        var result = Activity.demo.filter { filter == .all || $0.status.group == filter }
        switch sort {
        case .none: break
        case .descending: result.sort { $0.pts > $1.pts }
        case .ascending: result.sort { $0.pts < $1.pts }
        }
        return result
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                header
                ScoreCard(score: score)
                waysToEarnHeader
                ForEach(activities) { activity in
                    ActivityCard(activity: activity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(VIP.parchment)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("HSI EQUITY INNOVATION HUB")
                .font(.system(size: 10, weight: .bold))
                .kerning(0.8)
                .foregroundStyle(VIP.wordmark)
            Text("Amplifier")
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.34)
                .foregroundStyle(VIP.onyx)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private var waysToEarnHeader: some View {
        VStack(spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Ways to Earn")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(VIP.onyx)
                Spacer()
                Button {
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        sort = sort.next
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: sort.symbol)
                            .contentTransition(.identity)
                            .font(.system(size: 12, weight: .semibold))
                        Text(sort.label)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(sort == .none ? VIP.onyx.opacity(0.5) : VIP.cyan700)
                    .frame(minHeight: 28)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                ForEach(ActivityFilter.allCases, id: \.self) { option in
                    FilterChip(label: option.rawValue, isSelected: filter == option) {
                        filter = option
                    }
                }
                Spacer()
            }
        }
        .padding(.top, 8)
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? VIP.parchment : VIP.onyx.opacity(0.65))
                .padding(.horizontal, 14)
                .frame(minHeight: 32)
                .background(isSelected ? VIP.onyx : .clear)
                .overlay {
                    Capsule()
                        .strokeBorder(isSelected ? VIP.onyx : VIP.onyx.opacity(0.2), lineWidth: 1)
                }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ScoreCard: View {
    let score: Int

    private var progress: Tier.Progress { Tier.progress(for: score) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Your Amplifier Score")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(VIP.onyx.opacity(0.55))
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(VIP.cyan600)
                    Text(progress.tierName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(VIP.cyan700)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(VIP.cyan300.opacity(0.14))
                .overlay {
                    Capsule().strokeBorder(VIP.cyan600.opacity(0.25), lineWidth: 1)
                }
                .clipShape(Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(score.formatted())
                    .font(.system(size: 52, weight: .bold, design: .monospaced))
                    .foregroundStyle(VIP.cyan600)
                Text("pts")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(VIP.onyx.opacity(0.45))
            }
            .padding(.leading, 14)
            .overlay(alignment: .leading) {
                Rectangle().fill(VIP.cyan300).frame(width: 1)
            }

            VStack(spacing: 6) {
                GeometryReader { geo in
                    Capsule()
                        .fill(VIP.onyx.opacity(0.08))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(VIP.cyan300)
                                .frame(width: geo.size.width * progress.fraction)
                        }
                }
                .frame(height: 6)

                HStack {
                    Text(progress.progressLabel)
                        .foregroundStyle(VIP.onyx.opacity(0.55))
                    Spacer()
                    Text(progress.nextTierLabel)
                        .fontWeight(.semibold)
                        .foregroundStyle(VIP.cyan700)
                }
                .font(.system(size: 12))
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
}

private struct ActivityCard: View {
    let activity: Activity

    var body: some View {
        Button {
            // TODO: push Activity Detail screen
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: activity.symbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(activity.iconInk)
                    .frame(width: 40, height: 40)
                    .background(activity.iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(activity.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(VIP.onyx)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text("+\(activity.pts)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(VIP.cyan700)
                    }
                    Text(activity.desc)
                        .font(.system(size: 13))
                        .lineSpacing(3)
                        .foregroundStyle(VIP.onyx.opacity(0.6))
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 5) {
                        Image(systemName: activity.status.badgeSymbol)
                            .font(.system(size: 9, weight: .bold))
                        Text(activity.status.label)
                            .font(.system(size: 11.5, weight: .semibold))
                    }
                    .foregroundStyle(activity.status.badgeInk)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(activity.status.badgeBackground)
                    .clipShape(Capsule())
                    .padding(.top, 4)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(VIP.onyx.opacity(0.3))
                    .frame(maxHeight: .infinity)
            }
            .padding(16)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(activity.status.cardBorder, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}

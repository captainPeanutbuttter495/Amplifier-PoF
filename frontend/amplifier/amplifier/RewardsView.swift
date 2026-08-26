//
//  RewardsView.swift
//  amplifier
//
//  Implements "Amplifier Rewards.dc.html". The design's custom bottom sheet
//  becomes a native sheet with a medium detent.
//

import SwiftUI

struct Reward: Identifiable {
    let id: String
    let name: String
    let desc: String
    let cost: Int
    let availability: String
    let redeemInstructions: String
    let symbol: String
    let iconBackground: Color
    let iconInk: Color

    static let demo: [Reward] = [
        Reward(
            id: "tee", name: "Challenge Kickoff Tee",
            desc: "The official National Challenge launch tee.",
            cost: 400, availability: "24 left",
            redeemInstructions: "Show this screen at the ATEC front desk to pick up your tee. One per Amplifier.",
            symbol: "tshirt", iconBackground: VIP.cyan300.opacity(0.14), iconInk: VIP.cyan600
        ),
        Reward(
            id: "stickers", name: "Amplifier Sticker Pack",
            desc: "Culture is Currency sticker sheet for your laptop.",
            cost: 250, availability: "Plenty",
            redeemInstructions: "Show this screen at any Hub event table to pick up your sticker pack.",
            symbol: "doc", iconBackground: VIP.sky300.opacity(0.45), iconInk: VIP.jet
        ),
        Reward(
            id: "labpass", name: "ATEC Lab Day Pass",
            desc: "A day in the Autodesk Technology Engagement Center.",
            cost: 1000, availability: "Limited",
            redeemInstructions: "After redeeming, the Hub team will email you available dates for your lab day. Bring your student ID.",
            symbol: "ticket", iconBackground: VIP.wisteria400.opacity(0.2), iconInk: VIP.wisteriaInk
        ),
        Reward(
            id: "hoodie", name: "Hub Hoodie",
            desc: "Innovation Belongs To The People, on a hoodie.",
            cost: 1500, availability: "12 left",
            redeemInstructions: "Show this screen at the ATEC front desk to pick up your hoodie. One per Amplifier.",
            symbol: "tshirt", iconBackground: VIP.cyan300.opacity(0.14), iconInk: VIP.cyan600
        ),
        Reward(
            id: "vip", name: "Challenge Finals VIP Seat",
            desc: "Front-row seating at the National Challenge finals.",
            cost: 2000, availability: "8 left",
            redeemInstructions: "After redeeming, your name goes on the VIP list for finals day. The Hub team will confirm by email.",
            symbol: "star", iconBackground: VIP.logoYellow.opacity(0.28), iconInk: VIP.pendingInk
        ),
    ]
}

struct RewardsView: View {
    let lifetimePoints = 1640

    @State private var spent = 400
    @State private var redeemed: Set<String> = ["tee"]
    @State private var sheetReward: Reward?

    private var balance: Int { lifetimePoints - spent }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                header

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(Reward.demo) { reward in
                        RewardCard(reward: reward, state: state(for: reward)) {
                            sheetReward = reward
                        }
                    }
                }

                Text("Rewards and point thresholds are managed by the Hub and may change during the Challenge.")
                    .font(.system(size: 12))
                    .lineSpacing(3)
                    .foregroundStyle(VIP.onyx.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(VIP.parchment)
        .sheet(item: $sheetReward) { reward in
            RedeemSheet(reward: reward) {
                spent += reward.cost
                redeemed.insert(reward.id)
                sheetReward = nil
            }
        }
    }

    private func state(for reward: Reward) -> RewardCard.State {
        if redeemed.contains(reward.id) { return .redeemed }
        if balance < reward.cost { return .locked(shortBy: reward.cost - balance) }
        return .redeemable
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            Text("Rewards")
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.34)
                .foregroundStyle(VIP.onyx)
            Spacer()
            (
                Text(balance.formatted())
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(VIP.cyan600)
                + Text(" pts to spend")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(VIP.onyx.opacity(0.5))
            )
            .padding(.bottom, 4)
        }
        .padding(.bottom, 4)
    }
}

private struct RewardCard: View {
    enum State {
        case redeemable, redeemed
        case locked(shortBy: Int)
    }

    let reward: Reward
    let state: State
    let onTap: () -> Void

    private var isTappable: Bool {
        if case .redeemable = state { return true }
        return false
    }

    var body: some View {
        Button(action: { if isTappable { onTap() } }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: reward.symbol)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(reward.iconInk)
                        .frame(width: 40, height: 40)
                        .background(reward.iconBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Spacer()
                    Text(reward.availability)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(VIP.onyx.opacity(0.45))
                        .padding(.top, 2)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(reward.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(VIP.onyx)
                        .multilineTextAlignment(.leading)
                    Text(reward.desc)
                        .font(.system(size: 12))
                        .lineSpacing(2)
                        .foregroundStyle(VIP.onyx.opacity(0.55))
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)

                HStack {
                    Text(reward.cost.formatted())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(VIP.cyan700)
                    Spacer()
                    stateBadge
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 172, alignment: .topLeading)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .opacity({ if case .locked = state { 0.6 } else { 1 } }())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var stateBadge: some View {
        switch state {
        case .redeemed:
            badge("Redeemed", symbol: "checkmark",
                  background: VIP.cyan600.opacity(0.12), ink: VIP.cyan700)
        case .locked(let shortBy):
            badge("\(shortBy.formatted()) pts to go", symbol: "lock",
                  background: VIP.onyx.opacity(0.06), ink: VIP.onyx.opacity(0.55))
        case .redeemable:
            badge("Redeem", symbol: "arrow.right", background: VIP.cta, ink: .white)
        }
    }

    private func badge(_ label: String, symbol: String, background: Color, ink: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 9, weight: .bold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(ink)
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(background)
        .clipShape(Capsule())
    }
}

private struct RedeemSheet: View {
    let reward: Reward
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(reward.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(VIP.onyx)
                    Text("\(reward.availability) · picked up in person or by email")
                        .font(.system(size: 13))
                        .foregroundStyle(VIP.onyx.opacity(0.55))
                }
                Spacer()
                Text(reward.cost.formatted())
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(VIP.cyan600)
            }

            Text(reward.redeemInstructions)
                .font(.system(size: 13.5))
                .lineSpacing(3)
                .foregroundStyle(VIP.onyx.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(VIP.onyx.opacity(0.10), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Button(action: onConfirm) {
                Text("Redeem for \(reward.cost.formatted()) pts")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(VIP.cta)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            Button("Cancel") { dismiss() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(VIP.cyan600)
                .frame(minHeight: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(VIP.parchment)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    RewardsView()
}

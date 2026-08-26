//
//  SignInView.swift
//  amplifier
//
//  Implements "Amplifier Sign In.dc.html" from the Amplifier Home Screen
//  design project. Dark surface (carbon), VIP tokens throughout.
//

import SwiftUI

struct SignInView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Hero block — vertically centered in the remaining space
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("HSI EQUITY INNOVATION HUB")
                        .font(.system(size: 11, weight: .bold))
                        .kerning(0.9)
                        .foregroundStyle(VIP.ctaDark)
                    Text("Amplifier")
                        .font(.system(size: 46, weight: .bold))
                        .tracking(-0.46)
                        .foregroundStyle(VIP.parchment)
                }

                Text("Share the National Challenge with your friends, classmates, and community. Every verified share earns points, unlocks rewards, and moves you up the tiers.")
                    .font(.system(size: 16))
                    .lineSpacing(5)
                    .foregroundStyle(VIP.lightGrey.opacity(0.75))

                statsRow
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            // Auth actions pinned to the bottom
            VStack(spacing: 10) {
                AuthButton(style: .filled(background: VIP.parchment, foreground: VIP.onyx)) {
                    // TODO: Sign in with Apple via Auth0
                } label: {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 17, weight: .medium))
                    Text("Continue with Apple")
                }

                AuthButton(style: .outlined) {
                    // TODO: Sign in with Google via Auth0
                } label: {
                    Text("G")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(VIP.googleBlue)
                    Text("Continue with Google")
                }

                AuthButton(style: .filled(background: VIP.cta, foreground: .white)) {
                    // TODO: Sign in with email via Auth0
                } label: {
                    Image(systemName: "envelope")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Continue with Email")
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock")
                        .font(.system(size: 11))
                    Text("Secured by Auth0 · No CSUN sign-in needed")
                        .font(.system(size: 12))
                }
                .foregroundStyle(VIP.lightGrey.opacity(0.5))
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VIP.carbon)
        .preferredColorScheme(.dark)
    }

    private var statsRow: some View {
        HStack(spacing: 24) {
            StatBlock(value: "11,383", label: "Students Served")
            StatBlock(value: "646", label: "Educators in the Network")
        }
        .padding(.leading, 14)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(VIP.cyan300)
                .frame(width: 1)
        }
    }
}

private struct StatBlock: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundStyle(VIP.cyan300)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(VIP.lightGrey.opacity(0.6))
        }
    }
}

private struct AuthButton<Label: View>: View {
    enum Style {
        case filled(background: Color, foreground: Color)
        case outlined
    }

    let style: Style
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                label()
            }
            .font(.system(size: 16, weight: .semibold))
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background)
        .overlay {
            if case .outlined = style {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(VIP.lightGrey.opacity(0.25), lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var background: Color {
        if case let .filled(background, _) = style { return background }
        return .clear
    }

    private var foreground: Color {
        if case let .filled(_, foreground) = style { return foreground }
        return VIP.lightGrey
    }
}

#Preview {
    SignInView()
}

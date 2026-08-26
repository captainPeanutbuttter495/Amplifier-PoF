//
//  Theme.swift
//  amplifier
//
//  VIP brand tokens, ported from the design system
//  (_ds/.../tokens/colors.css + semantic.css). Hex values are the
//  design-system spec values noted in the token comments.
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum VIP {
    // Neutrals
    static let onyx = Color(hex: 0x121316)
    static let carbon = Color(hex: 0x1A1C20)
    static let jet = Color(hex: 0x2C3740)
    static let parchment = Color(hex: 0xF2EEE9)
    static let lightGrey = Color(hex: 0xE8E8E8)

    // Immersive Cyan
    static let cyan300 = Color(hex: 0x4ECDC4)

    // CTA
    static let cta = Color(hex: 0xBD3547)
    static let ctaDark = Color(hex: 0xF1A7B1)   // dark-surface variant

    // Google brand blue (logo glyph)
    static let googleBlue = Color(hex: 0x4285F4)
}

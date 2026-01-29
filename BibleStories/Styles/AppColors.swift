//
//  AppColors.swift
//  BibleStories
//
//  Color palette for the app.
//

import SwiftUI

enum AppColors {
    // MARK: - Background Colors
    static let celestialDeep = Color(red: 0.05, green: 0.08, blue: 0.18)
    static let celestialMid = Color(red: 0.10, green: 0.15, blue: 0.35)
    static let celestialLight = Color(red: 0.20, green: 0.25, blue: 0.50)

    // MARK: - Accent Colors
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.40)
    static let warmOrange = Color(red: 1.0, green: 0.60, blue: 0.30)
    static let softPink = Color(red: 1.0, green: 0.75, blue: 0.80)

    // MARK: - UI Colors
    static let stickerBorder = Color.white
    static let stickerShadow = Color.black.opacity(0.3)
    static let lockOverlay = Color.black.opacity(0.5)

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textOnDark = Color.white

    // MARK: - Star Colors
    static let starBright = Color.white
    static let starDim = Color.white.opacity(0.6)
    static let starGlow = Color(red: 0.8, green: 0.9, blue: 1.0)

    // MARK: - Gradients
    static let celestialGradient = LinearGradient(
        colors: [celestialDeep, celestialMid, celestialLight],
        startPoint: .top,
        endPoint: .bottom
    )

    static let goldGradient = LinearGradient(
        colors: [gold, warmOrange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let textOverlayGradient = LinearGradient(
        colors: [Color.clear, Color.black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
}

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

    // MARK: - Home Screen Colors
    static let homeButtonBlue = Color(red: 0.25, green: 0.55, blue: 0.95)
    static let bookOrange = Color(red: 0.90, green: 0.65, blue: 0.45)  // #E6A672
    static let bookPurple = Color(red: 0.64, green: 0.45, blue: 0.90)  // #A272E6
    static let bookCyan = Color(red: 0.45, green: 0.79, blue: 0.90)    // #72C9E6
    static let unlockButtonOrange = Color(red: 1.0, green: 0.34, blue: 0.0)  // #FF5700
    static let unlockButtonOrangeDark = Color(red: 1.0, green: 0.22, blue: 0.0)  // #FF3800

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

//
//  StickerStyle.swift
//  BibleStories
//
//  Sticker aesthetic styling for the app.
//

import SwiftUI

// MARK: - Sticker Border Modifier

struct StickerBorder: ViewModifier {
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 3
    var borderColor: Color = AppColors.stickerBorder

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: AppColors.stickerShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Sticker Card Modifier

struct StickerCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var borderWidth: CGFloat = 3
    var borderColor: Color = AppColors.stickerBorder
    var backgroundColor: Color = AppColors.celestialMid

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: AppColors.stickerShadow, radius: 8, x: 0, y: 4)
    }
}

// MARK: - Squish Animation Modifier

struct SquishEffect: ViewModifier {
    @Binding var isPressed: Bool
    var scale: CGFloat = 0.92

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.spring(duration: 0.2, bounce: 0.4), value: isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func stickerBorder(
        cornerRadius: CGFloat = 20,
        borderWidth: CGFloat = 3,
        borderColor: Color = AppColors.stickerBorder
    ) -> some View {
        modifier(StickerBorder(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor
        ))
    }

    func stickerCard(
        cornerRadius: CGFloat = 16,
        borderWidth: CGFloat = 3,
        borderColor: Color = AppColors.stickerBorder,
        backgroundColor: Color = AppColors.celestialMid
    ) -> some View {
        modifier(StickerCard(
            cornerRadius: cornerRadius,
            borderWidth: borderWidth,
            borderColor: borderColor,
            backgroundColor: backgroundColor
        ))
    }

    func squishEffect(isPressed: Binding<Bool>, scale: CGFloat = 0.92) -> some View {
        modifier(SquishEffect(isPressed: isPressed, scale: scale))
    }
}

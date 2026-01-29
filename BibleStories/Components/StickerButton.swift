//
//  StickerButton.swift
//  BibleStories
//
//  Squish animation button with sticker aesthetic.
//

import SwiftUI

struct StickerButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            label()
                .squishEffect(isPressed: $isPressed)
        }
        .buttonStyle(StickerButtonStyle(isPressed: $isPressed))
    }

    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

// MARK: - Sticker Button Style

struct StickerButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Icon Button Variant

struct StickerIconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var backgroundColor: Color = AppColors.celestialMid

    @State private var isPressed = false

    var body: some View {
        StickerButton(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)

                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .overlay(
                Circle()
                    .strokeBorder(AppColors.stickerBorder, lineWidth: 2)
            )
            .shadow(color: AppColors.stickerShadow, radius: 6, x: 0, y: 3)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        VStack(spacing: 24) {
            StickerButton(action: { print("Tapped!") }) {
                Text("Read Story")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(AppColors.gold)
                    .stickerBorder(cornerRadius: 28)
            }

            HStack(spacing: 16) {
                StickerIconButton(systemName: "gearshape.fill", action: {})
                StickerIconButton(systemName: "envelope.fill", action: {})
                StickerIconButton(systemName: "music.note", action: {})
            }
        }
    }
}

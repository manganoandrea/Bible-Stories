//
//  GiftBadge.swift
//  BibleStories
//
//  Mascot reward indicator badge.
//

import SwiftUI

struct GiftBadge: View {
    let mascotName: String?
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            // Badge background
            Circle()
                .fill(AppColors.gold)
                .frame(width: size, height: size)

            // Gift icon or mascot initial
            if let name = mascotName, !name.isEmpty {
                Text(mascotIcon(for: name))
                    .font(.system(size: size * 0.5))
            } else {
                Image(systemName: "gift.fill")
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundStyle(AppColors.celestialDeep)
            }
        }
        .overlay(
            Circle()
                .strokeBorder(AppColors.stickerBorder, lineWidth: 2)
        )
        .shadow(color: AppColors.stickerShadow, radius: 4, x: 0, y: 2)
    }

    private func mascotIcon(for name: String) -> String {
        switch name.lowercased() {
        case "dove": return "🕊️"
        case "lion": return "🦁"
        case "sheep", "lamb": return "🐑"
        case "whale": return "🐋"
        case "fish": return "🐟"
        case "donkey": return "🫏"
        default: return "🎁"
        }
    }
}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        HStack(spacing: 20) {
            GiftBadge(mascotName: "Dove")
            GiftBadge(mascotName: "Lion")
            GiftBadge(mascotName: "Whale")
            GiftBadge(mascotName: nil)
        }
    }
}

//
//  LockOverlay.swift
//  BibleStories
//
//  Locked book indicator overlay.
//

import SwiftUI

struct LockOverlay: View {
    var cornerRadius: CGFloat = 16

    var body: some View {
        ZStack {
            // Dimming overlay
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.lockOverlay)

            // Lock icon
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Locked")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(16)
            .background(
                Circle()
                    .fill(AppColors.celestialDeep.opacity(0.8))
                    .frame(width: 80, height: 80)
            )
        }
    }
}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray)
            .frame(width: 200, height: 280)
            .overlay(LockOverlay())
    }
}

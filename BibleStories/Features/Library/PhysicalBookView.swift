//
//  PhysicalBookView.swift
//  BibleStories
//
//  A 3D-styled book with cover, pages, and binding.
//

import SwiftUI
import UIKit

struct PhysicalBookView: View {
    let coverImage: UIImage?
    let title: String
    let isLocked: Bool
    let size: CGSize

    // MARK: - Design Constants
    // Cover: 180w × 212h, Pages: 6px, Binding: 5px (top-right, right, bottom-right)

    private let cornerRadius: CGFloat = 6

    // Proportions based on base dimensions
    private let baseCoverWidth: CGFloat = 180
    private let baseBookWidth: CGFloat = 191  // 180 + 6 + 5
    private let baseBookHeight: CGFloat = 212
    private let basePageWidth: CGFloat = 6
    private let baseBindingWidth: CGFloat = 5

    private var scale: CGFloat { size.width / baseBookWidth }

    private var coverWidth: CGFloat { baseCoverWidth * scale }
    private var pageWidth: CGFloat { basePageWidth * scale }
    private var bindingWidth: CGFloat { baseBindingWidth * scale }
    private var bindingInset: CGFloat { baseBindingWidth * scale }  // 5px top/bottom

    // Fallback colors
    private static let fallbackBindingColor = Color(red: 0.075, green: 0.384, blue: 0.431)  // #13626E

    /// Dynamic binding color - extracted from image + 20% lighter
    private var bindingColor: Color {
        guard let image = coverImage else {
            return Self.fallbackBindingColor
        }
        return image.dominantColorFromLeftEdge().adjustedBrightness(by: 0.20)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Layer 3 (bottom): Binding - teal background with rounded corners on right
            bindingView

            // Layer 2 (middle): Pages - white, inset from binding
            pagesView

            // Layer 1 (top): Cover - full height, on top of everything
            coverView
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }

    // MARK: - Binding View (bottom layer)

    private var bindingView: some View {
        HStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(bindingColor)
                .frame(width: pageWidth + bindingWidth)
        }
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: cornerRadius
            )
        )
    }

    // MARK: - Pages View (middle layer)

    private var pagesView: some View {
        HStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(Color.white)
                .frame(width: pageWidth)
                .padding(.top, bindingInset)
                .padding(.bottom, bindingInset)
                .padding(.trailing, bindingWidth)
        }
    }

    // MARK: - Cover View (top layer)

    private var coverView: some View {
        ZStack {
            // Cover background
            Rectangle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))

            // Cover image
            if let image = coverImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: coverWidth, height: size.height)
                    .clipped()
            }

            // Title at bottom with gradient
            VStack {
                Spacer()
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            // Lock overlay
            if isLocked {
                Color.black.opacity(0.6)
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .frame(width: coverWidth, height: size.height)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: cornerRadius,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        )
    }
}

// MARK: - Color Brightness Extension

private extension Color {
    func adjustedBrightness(by percentage: CGFloat) -> Color {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return self
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        if percentage > 0 {
            return Color(
                red: min(1.0, r + (1.0 - r) * percentage),
                green: min(1.0, g + (1.0 - g) * percentage),
                blue: min(1.0, b + (1.0 - b) * percentage)
            )
        } else {
            let factor = 1.0 + percentage
            return Color(
                red: max(0, r * factor),
                green: max(0, g * factor),
                blue: max(0, b * factor)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        CelestialVaultBackground()
            .ignoresSafeArea()

        HStack(spacing: 30) {
            PhysicalBookView(
                coverImage: UIImage(named: "page_00"),
                title: "Adam & Eve",
                isLocked: false,
                size: CGSize(width: 191, height: 212)
            )

            PhysicalBookView(
                coverImage: nil,
                title: "Noah's Ark",
                isLocked: true,
                size: CGSize(width: 191, height: 212)
            )
        }
    }
}

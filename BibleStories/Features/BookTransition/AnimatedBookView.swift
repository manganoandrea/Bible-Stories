//
//  AnimatedBookView.swift
//  BibleStories
//
//  Animated book component that composes PhysicalBookView for flip animations.
//

import SwiftUI
import UIKit

struct AnimatedBookView: View {
    let coverImage: UIImage?
    let firstPageImage: UIImage?
    let size: CGSize
    let flipAngle: Double  // 0 = closed, 180 = fully open
    let showSpread: Bool

    // MARK: - Design Constants

    private let cornerRadius: CGFloat = 6
    private let perspective: CGFloat = 0.35
    private let gutterWidth: CGFloat = 20
    private let gutterShadowOpacity: Double = 0.2

    // Proportions from PhysicalBookView (191w base)
    private var coverWidth: CGFloat { size.width * (180.0 / 191.0) }
    private var pageWidth: CGFloat { size.width * (6.0 / 191.0) }
    private var bindingWidth: CGFloat { size.width * (5.0 / 191.0) }

    // Primary color for back of cover and binding
    private var primaryColor: Color {
        guard let image = coverImage else {
            return Color(red: 0.075, green: 0.384, blue: 0.431)  // Fallback teal
        }
        return image.dominantColorFromLeftEdge().adjustedBrightness(by: 0.20)
    }

    var body: some View {
        ZStack {
            // Layer 1: Two-page spread (revealed when cover opens)
            if flipAngle > 30 {
                spreadView
                    .opacity(spreadOpacity)
            }

            // Layer 2: Book back (binding color, visible when cover flips)
            if flipAngle > 10 && flipAngle < 170 {
                bookBackView
                    .opacity(bookBackOpacity)
            }

            // Layer 3: Cover (flips open)
            coverView
                .rotation3DEffect(
                    .degrees(-flipAngle),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: perspective
                )
                .opacity(coverOpacity)
        }
        .frame(width: spreadWidth, height: size.height)
        .shadow(color: .black.opacity(0.25), radius: shadowRadius, x: shadowOffsetX, y: 4)
    }

    // MARK: - Spread Width (grows as book opens)

    private var spreadWidth: CGFloat {
        if showSpread && flipAngle >= 170 {
            return size.width * 2  // Full spread width
        }
        return size.width
    }

    // MARK: - Cover View (PhysicalBookView style)

    private var coverView: some View {
        ZStack(alignment: .leading) {
            // Cover content
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.25))

                if let image = coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: coverWidth, height: size.height)
                        .clipped()
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

            // Pages (right side of cover)
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(width: pageWidth)
                    .padding(.top, bindingWidth)
                    .padding(.bottom, bindingWidth)

                Rectangle()
                    .fill(primaryColor)
                    .frame(width: bindingWidth)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    )
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    // MARK: - Book Back View (visible during flip)

    private var bookBackView: some View {
        Rectangle()
            .fill(primaryColor)
            .frame(width: size.width / 2, height: size.height)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: cornerRadius,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )
            .offset(x: -size.width / 4)
    }

    // MARK: - Spread View (two-page spread)

    private var spreadView: some View {
        ZStack {
            // Binding frame (background)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(primaryColor)

            // White page area
            RoundedRectangle(cornerRadius: cornerRadius - 2)
                .fill(Color.white)
                .padding(bindingWidth)

            // Page content
            HStack(spacing: 0) {
                // Left page
                pageView(isLeft: true)

                // Right page
                pageView(isLeft: false)
            }
            .padding(bindingWidth + 2)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 2))

            // Gutter shadow
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(gutterShadowOpacity),
                            .black.opacity(gutterShadowOpacity * 1.3),
                            .black.opacity(gutterShadowOpacity),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: gutterWidth)
        }
        .frame(width: size.width * 2, height: size.height)
    }

    @ViewBuilder
    private func pageView(isLeft: Bool) -> some View {
        if let pageImage = firstPageImage {
            let halfWidth = (size.width * 2 - bindingWidth * 2 - 4) / 2

            Image(uiImage: pageImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: halfWidth, height: size.height - bindingWidth * 2 - 4)
                .clipped()
                .offset(x: isLeft ? halfWidth / 2 : -halfWidth / 2)
                .frame(width: halfWidth)
                .clipped()
        } else {
            Rectangle()
                .fill(Color(red: 0.95, green: 0.93, blue: 0.9))
        }
    }

    // MARK: - Opacity Calculations

    private var coverOpacity: Double {
        flipAngle < 170 ? 1.0 : 0.0
    }

    private var bookBackOpacity: Double {
        let fadeIn = min(1.0, (flipAngle - 10) / 30)
        let fadeOut = min(1.0, (170 - flipAngle) / 30)
        return min(fadeIn, fadeOut)
    }

    private var spreadOpacity: Double {
        if flipAngle < 30 { return 0 }
        if flipAngle < 90 { return (flipAngle - 30) / 60 }
        return 1.0
    }

    // MARK: - Shadow Calculations

    private var shadowRadius: CGFloat {
        let base: CGFloat = 12
        let additional: CGFloat = 16
        let progress = min(flipAngle, 90) / 90
        return base + (additional * progress)
    }

    private var shadowOffsetX: CGFloat {
        let maxOffset: CGFloat = 20
        return -maxOffset * sin(flipAngle * .pi / 180)
    }
}

// MARK: - Color Extension

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

        VStack(spacing: 40) {
            // Closed
            AnimatedBookView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 191, height: 212),
                flipAngle: 0,
                showSpread: false
            )

            // Mid-flip
            AnimatedBookView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 191, height: 212),
                flipAngle: 90,
                showSpread: false
            )

            // Open spread
            AnimatedBookView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 191, height: 212),
                flipAngle: 180,
                showSpread: true
            )
        }
    }
}

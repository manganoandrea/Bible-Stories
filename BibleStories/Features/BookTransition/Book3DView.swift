//
//  Book3DView.swift
//  BibleStories
//
//  Renders a 3D book with cover, spine, page edges, and two-page spread.
//

import SwiftUI

struct Book3DView: View {
    let coverImage: UIImage?
    let leftHalfImage: UIImage?    // Left half of first page
    let rightHalfImage: UIImage?   // Right half of first page
    let size: CGSize
    let flipAngle: Double // 0 = closed, 180 = fully open
    let spineWidth: CGFloat
    let showSpread: Bool           // Show two-page spread mode

    private let pageEdgeColor = Color(white: 0.95)

    // MARK: - Constants
    private let cornerRadius: CGFloat = 16
    private let spineOpacityStartAngle: Double = 15
    private let spineOpacityEndAngle: Double = 165
    private let coverFadeAngle: Double = 170
    private let firstPageRevealAngle: Double = 70
    private let spreadRevealAngle: Double = 170
    private let defaultSpineColor = Color(red: 0.4, green: 0.25, blue: 0.15)
    private let gutterWidth: CGFloat = 24
    private let gutterShadowOpacity: Double = 0.15
    private let spineThicknessMultiplier: CGFloat = 2.5 // Thicker spine for more dramatic 3D
    private let perspectiveAmount: CGFloat = 0.35 // More dramatic perspective

    private var spineColor: Color {
        coverImage?.dominantColorFromLeftEdge() ?? defaultSpineColor
    }

    var body: some View {
        ZStack {
            // Layer 1: Spread view OR first page during flip
            if showSpread && flipAngle >= spreadRevealAngle {
                spreadView
            } else if flipAngle > firstPageRevealAngle {
                firstPageView
                    .opacity(firstPageOpacity)
            }

            // Layer 2: Page edges (visible during flip, hidden in spread mode)
            if !showSpread || flipAngle < spreadRevealAngle {
                pageEdgesView
                    .opacity(pageEdgesOpacity)
            }

            // Layer 3: Spine (visible during flip, hidden in spread mode)
            if !showSpread || flipAngle < spreadRevealAngle {
                spineView
                    .opacity(spineOpacity)
            }

            // Layer 4: Front cover (flips open)
            coverView
                .rotation3DEffect(
                    .degrees(-flipAngle),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: perspectiveAmount
                )
                .opacity(coverOpacity)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var coverView: some View {
        if let image = coverImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: shadowOffsetY)
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColors.celestialMid)
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.gold)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
            )
    }

    @ViewBuilder
    private var spreadView: some View {
        HStack(spacing: 0) {
            // Left page
            if let leftImage = leftHalfImage {
                Image(uiImage: leftImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width / 2, height: size.height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColors.celestialLight)
                    .frame(width: size.width / 2, height: size.height)
            }

            // Right page
            if let rightImage = rightHalfImage {
                Image(uiImage: rightImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width / 2, height: size.height)
                    .clipped()
            } else {
                Rectangle()
                    .fill(AppColors.celestialLight)
                    .frame(width: size.width / 2, height: size.height)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            // Gutter shadow in center
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .black.opacity(gutterShadowOpacity),
                            .black.opacity(gutterShadowOpacity * 1.2),
                            .black.opacity(gutterShadowOpacity),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: gutterWidth)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
        )
    }

    @ViewBuilder
    private var firstPageView: some View {
        // During flip, show right half peeking out
        if let rightImage = rightHalfImage {
            Image(uiImage: rightImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width / 2, height: size.height)
                .clipped()
                .clipShape(
                    RoundedRectangle(cornerRadius: cornerRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
                .offset(x: size.width / 4) // Position on right side
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.celestialLight)
                .frame(width: size.width / 2, height: size.height)
                .offset(x: size.width / 4)
        }
    }

    private var spineView: some View {
        // Spine positioned at the left edge, rotated to face camera during flip
        let thickSpineWidth = spineWidth * spineThicknessMultiplier

        return Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        spineColor.opacity(0.6),
                        spineColor,
                        spineColor.opacity(0.85),
                        spineColor,
                        spineColor.opacity(0.6)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: thickSpineWidth, height: size.height)
            .overlay(
                // Spine detail lines for book texture
                HStack(spacing: thickSpineWidth * 0.3) {
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 1)
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.3), radius: 4, x: -2, y: 0)
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: perspectiveAmount
            )
            .offset(x: -size.width / 2 + thickSpineWidth / 2)
    }

    private var pageEdgesView: some View {
        // Page edges - cream colored strip representing closed pages
        let thickSpineWidth = spineWidth * spineThicknessMultiplier
        let pageEdgeWidth = thickSpineWidth * 0.6

        return Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        pageEdgeColor.opacity(0.95),
                        pageEdgeColor,
                        pageEdgeColor.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: pageEdgeWidth, height: size.height - 8)
            .overlay(
                // Page lines for realistic book texture
                VStack(spacing: 1.5) {
                    ForEach(0..<12, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.08))
                            .frame(height: 0.5)
                    }
                }
                .padding(.vertical, 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 0)
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: perspectiveAmount
            )
            .offset(x: -size.width / 2 + thickSpineWidth + (pageEdgeWidth * 0.5))
    }

    // MARK: - Computed Properties

    private var coverOpacity: Double {
        flipAngle < coverFadeAngle ? 1.0 : 0.0
    }

    private var firstPageOpacity: Double {
        if flipAngle <= firstPageRevealAngle { return 0 }
        if showSpread && flipAngle >= spreadRevealAngle { return 0 }
        return min(1.0, (flipAngle - firstPageRevealAngle) / 45)
    }

    private var spineOpacity: Double {
        // Visible from spineOpacityStartAngle to spineOpacityEndAngle
        if flipAngle < spineOpacityStartAngle { return flipAngle / spineOpacityStartAngle }
        if flipAngle > spineOpacityEndAngle { return (180 - flipAngle) / spineOpacityStartAngle }
        return 1.0
    }

    private var pageEdgesOpacity: Double {
        spineOpacity * 0.9
    }

    private var shadowRadius: CGFloat {
        // Shadow grows significantly as book lifts for dramatic effect
        let baseRadius: CGFloat = 10
        let maxAdditional: CGFloat = 20
        let progress = min(flipAngle, 90) / 90
        return baseRadius + (maxAdditional * progress)
    }

    private var shadowOffsetX: CGFloat {
        // Shadow shifts with rotation - more dramatic offset
        let maxOffset: CGFloat = 25
        return -maxOffset * sin(flipAngle * .pi / 180)
    }

    private var shadowOffsetY: CGFloat {
        // Shadow also moves down as book lifts
        let baseOffset: CGFloat = 6
        let maxAdditional: CGFloat = 12
        let progress = min(flipAngle, 90) / 90
        return baseOffset + (maxAdditional * progress)
    }

    private var shadowColor: Color {
        AppColors.stickerShadow.opacity(0.35 + 0.25 * min(flipAngle, 90) / 90)
    }

}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Book3DView(
                coverImage: UIImage(named: "page_00"),
                leftHalfImage: UIImage(named: "page_01")?.leftHalf(),
                rightHalfImage: UIImage(named: "page_01")?.rightHalf(),
                size: CGSize(width: 200, height: 280),
                flipAngle: 0,
                spineWidth: 14,
                showSpread: false
            )

            Book3DView(
                coverImage: UIImage(named: "page_00"),
                leftHalfImage: UIImage(named: "page_01")?.leftHalf(),
                rightHalfImage: UIImage(named: "page_01")?.rightHalf(),
                size: CGSize(width: 400, height: 280),
                flipAngle: 180,
                spineWidth: 14,
                showSpread: true
            )
        }
    }
}

//
//  Book3DView.swift
//  BibleStories
//
//  Renders a 3D book with cover, spine, and page edges.
//

import SwiftUI

struct Book3DView: View {
    let coverImage: UIImage?
    let firstPageImage: UIImage?
    let size: CGSize
    let flipAngle: Double // 0 = closed, 180 = fully open
    let spineWidth: CGFloat

    private let pageEdgeColor = Color(white: 0.95)

    // MARK: - Constants
    private let cornerRadius: CGFloat = 16
    private let spineOpacityStartAngle: Double = 20
    private let spineOpacityEndAngle: Double = 160
    private let coverFadeAngle: Double = 170
    private let firstPageRevealAngle: Double = 90
    private let defaultSpineColor = Color(red: 0.4, green: 0.25, blue: 0.15)

    private var spineColor: Color {
        coverImage?.dominantColorFromLeftEdge() ?? defaultSpineColor
    }

    var body: some View {
        ZStack {
            // Layer 1: First page (revealed when angle > firstPageRevealAngle)
            if flipAngle > firstPageRevealAngle {
                firstPageView
                    .opacity(firstPageOpacity)
            }

            // Layer 2: Page edges (visible during flip)
            pageEdgesView
                .opacity(pageEdgesOpacity)

            // Layer 3: Spine (visible during flip)
            spineView
                .opacity(spineOpacity)

            // Layer 4: Front cover (flips open)
            coverView
                .rotation3DEffect(
                    .degrees(-flipAngle),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: 0.5
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
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: 6)
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
    private var firstPageView: some View {
        if let image = firstPageImage {
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
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.celestialLight)
                .frame(width: size.width, height: size.height)
        }
    }

    private var spineView: some View {
        // Spine positioned at the left edge, rotated to face camera during flip
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        spineColor.opacity(0.7),
                        spineColor,
                        spineColor.opacity(0.5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: spineWidth, height: size.height)
            .overlay(
                // Spine detail line
                Rectangle()
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 1)
                    .offset(x: -spineWidth / 2 + 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.5
            )
            .offset(x: -size.width / 2 + spineWidth / 2)
    }

    private var pageEdgesView: some View {
        // Page edges - cream colored strip representing closed pages
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        pageEdgeColor.opacity(0.9),
                        pageEdgeColor,
                        pageEdgeColor.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: spineWidth * 0.8, height: size.height - 8)
            .overlay(
                // Page lines
                VStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 0.5)
                    }
                }
                .padding(.vertical, 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .rotation3DEffect(
                .degrees(90 - flipAngle / 2),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.5
            )
            .offset(x: -size.width / 2 + spineWidth + (spineWidth * 0.4))
    }

    // MARK: - Computed Properties

    private var coverOpacity: Double {
        flipAngle < coverFadeAngle ? 1.0 : 0.0
    }

    private var firstPageOpacity: Double {
        if flipAngle <= firstPageRevealAngle { return 0 }
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
        // Shadow grows as book lifts
        let baseRadius: CGFloat = 8
        let maxAdditional: CGFloat = 12
        let progress = min(flipAngle, 90) / 90
        return baseRadius + (maxAdditional * progress)
    }

    private var shadowOffsetX: CGFloat {
        // Shadow shifts with rotation
        let maxOffset: CGFloat = 15
        return -maxOffset * sin(flipAngle * .pi / 180)
    }

    private var shadowColor: Color {
        AppColors.stickerShadow.opacity(0.3 + 0.2 * min(flipAngle, 90) / 90)
    }

}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Book3DView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 200, height: 280),
                flipAngle: 0,
                spineWidth: 14
            )

            Book3DView(
                coverImage: UIImage(named: "page_00"),
                firstPageImage: UIImage(named: "page_01"),
                size: CGSize(width: 200, height: 280),
                flipAngle: 90,
                spineWidth: 14
            )
        }
    }
}

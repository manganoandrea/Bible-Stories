//
//  AdaptiveFrame.swift
//  BibleStories
//
//  Adaptive color frame with corner decorations for story pages.
//

import SwiftUI

struct AdaptiveFrameModifier: ViewModifier {
    let frameColor: Color
    let frameWidth: CGFloat
    let cornerRadius: CGFloat
    let showCornerDots: Bool

    init(
        frameColor: Color,
        frameWidth: CGFloat = 10,
        cornerRadius: CGFloat = 12,
        showCornerDots: Bool = true
    ) {
        self.frameColor = frameColor
        self.frameWidth = frameWidth
        self.cornerRadius = cornerRadius
        self.showCornerDots = showCornerDots
    }

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(frameWidth)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius + frameWidth * 0.5)
                    .fill(frameColor)
            )
            .overlay(
                // Corner dots
                cornerDotsOverlay
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius + frameWidth * 0.5))
    }

    @ViewBuilder
    private var cornerDotsOverlay: some View {
        if showCornerDots {
            GeometryReader { geometry in
                let dotSize: CGFloat = 8
                let dotOffset: CGFloat = frameWidth * 0.5

                // Top-left dot
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .position(x: dotOffset + dotSize / 2, y: dotOffset + dotSize / 2)

                // Top-right dot
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .position(x: geometry.size.width - dotOffset - dotSize / 2, y: dotOffset + dotSize / 2)

                // Bottom-left dot
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .position(x: dotOffset + dotSize / 2, y: geometry.size.height - dotOffset - dotSize / 2)

                // Bottom-right dot
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: dotSize, height: dotSize)
                    .position(x: geometry.size.width - dotOffset - dotSize / 2, y: geometry.size.height - dotOffset - dotSize / 2)
            }
        }
    }
}

// MARK: - View Extension

extension View {
    func adaptiveFrame(
        color: Color,
        width: CGFloat = 10,
        cornerRadius: CGFloat = 12,
        showCornerDots: Bool = true
    ) -> some View {
        modifier(AdaptiveFrameModifier(
            frameColor: color,
            frameWidth: width,
            cornerRadius: cornerRadius,
            showCornerDots: showCornerDots
        ))
    }
}

// MARK: - Adaptive Frame Container

/// A container view that extracts color from an image and applies an adaptive frame
struct AdaptiveFrameContainer<Content: View>: View {
    let imageAsset: String
    let content: Content

    @State private var frameColor: Color = .gray

    init(imageAsset: String, @ViewBuilder content: () -> Content) {
        self.imageAsset = imageAsset
        self.content = content()
    }

    var body: some View {
        content
            .adaptiveFrame(color: frameColor)
            .onAppear {
                extractFrameColor()
            }
            .onChange(of: imageAsset) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    extractFrameColor()
                }
            }
    }

    private func extractFrameColor() {
        if let image = UIImage(named: imageAsset) {
            frameColor = image.dominantColorFromEdges()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 20) {
            // Sample with extracted color
            if let image = UIImage(named: "page_00") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .adaptiveFrame(color: image.dominantColorFromEdges())
            }

            // Sample with manual color
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 150)
                .adaptiveFrame(color: .teal)
        }
        .padding()
    }
}

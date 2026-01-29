//
//  CelestialVaultBackground.swift
//  BibleStories
//
//  Animated starfield background with celestial theme.
//

import SwiftUI

struct CelestialVaultBackground: View {
    @State private var stars: [Star] = []
    @State private var isAnimating = false

    private let starCount = 80

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                // Draw gradient background
                let gradient = Gradient(colors: [
                    AppColors.celestialDeep,
                    AppColors.celestialMid,
                    AppColors.celestialLight
                ])
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        gradient,
                        startPoint: .zero,
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )

                // Draw stars
                let time = timeline.date.timeIntervalSinceReferenceDate
                for star in stars {
                    drawStar(context: context, star: star, time: time, size: size)
                }
            }
        }
        .drawingGroup() // Metal-accelerated rendering
        .onAppear {
            generateStars()
        }
    }

    private func generateStars() {
        stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...4),
                brightness: CGFloat.random(in: 0.4...1.0),
                twinkleSpeed: Double.random(in: 0.5...2.0),
                twinkleOffset: Double.random(in: 0...Double.pi * 2),
                driftSpeed: CGFloat.random(in: 0.001...0.003),
                driftDirection: CGFloat.random(in: 0...Double.pi * 2)
            )
        }
    }

    private func drawStar(context: GraphicsContext, star: Star, time: TimeInterval, size: CGSize) {
        // Calculate twinkling
        let twinkle = sin(time * star.twinkleSpeed + star.twinkleOffset)
        let currentBrightness = star.brightness * (0.7 + 0.3 * twinkle)

        // Calculate drift
        let driftX = sin(time * 0.1 + star.driftDirection) * star.driftSpeed
        let driftY = cos(time * 0.1 + star.driftDirection) * star.driftSpeed

        // Calculate position
        var x = (star.x + driftX * CGFloat(time.truncatingRemainder(dividingBy: 100))).truncatingRemainder(dividingBy: 1)
        var y = (star.y + driftY * CGFloat(time.truncatingRemainder(dividingBy: 100))).truncatingRemainder(dividingBy: 1)
        if x < 0 { x += 1 }
        if y < 0 { y += 1 }

        let point = CGPoint(x: x * size.width, y: y * size.height)

        // Draw glow
        if star.size > 2 {
            let glowSize = star.size * 4
            let glowRect = CGRect(
                x: point.x - glowSize / 2,
                y: point.y - glowSize / 2,
                width: glowSize,
                height: glowSize
            )
            context.fill(
                Path(ellipseIn: glowRect),
                with: .color(AppColors.starGlow.opacity(currentBrightness * 0.2))
            )
        }

        // Draw star
        let starRect = CGRect(
            x: point.x - star.size / 2,
            y: point.y - star.size / 2,
            width: star.size,
            height: star.size
        )
        context.fill(
            Path(ellipseIn: starRect),
            with: .color(AppColors.starBright.opacity(currentBrightness))
        )
    }
}

// MARK: - Star Model

private struct Star {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let brightness: CGFloat
    let twinkleSpeed: Double
    let twinkleOffset: Double
    let driftSpeed: CGFloat
    let driftDirection: CGFloat
}

#Preview {
    CelestialVaultBackground()
        .ignoresSafeArea()
}

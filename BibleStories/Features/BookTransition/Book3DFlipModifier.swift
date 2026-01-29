//
//  Book3DFlipModifier.swift
//  BibleStories
//
//  3D rotation effect wrapper for book flip animation.
//

import SwiftUI

struct Book3DFlipModifier: ViewModifier {
    let angle: Double
    var perspective: CGFloat = 0.6
    var anchor: UnitPoint = .leading

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                anchor: anchor,
                anchorZ: 0,
                perspective: perspective
            )
    }
}

extension View {
    func book3DFlip(
        angle: Double,
        perspective: CGFloat = 0.6,
        anchor: UnitPoint = .leading
    ) -> some View {
        modifier(Book3DFlipModifier(
            angle: angle,
            perspective: perspective,
            anchor: anchor
        ))
    }
}

// MARK: - Book Spine Effect

struct BookSpineView: View {
    let width: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        color.opacity(0.8),
                        color,
                        color.opacity(0.6)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 1)
                    .offset(x: -width / 2 + 1)
            )
    }
}

#Preview {
    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        VStack(spacing: 40) {
            // Closed book
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.gold)
                .frame(width: 150, height: 200)
                .book3DFlip(angle: 0)

            // Partially open
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.gold)
                .frame(width: 150, height: 200)
                .book3DFlip(angle: -45)

            // Fully open
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.gold)
                .frame(width: 150, height: 200)
                .book3DFlip(angle: -90)
        }
    }
}

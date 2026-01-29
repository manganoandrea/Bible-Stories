//
//  TransitionCoordinator.swift
//  BibleStories
//
//  GeometryReader positioning for book transitions.
//

import SwiftUI

struct TransitionCoordinator {
    let screenSize: CGSize

    // Target size for the centered book (before flip)
    var centeredBookSize: CGSize {
        let width = min(screenSize.width * 0.35, 300)
        let height = width * 1.4 // Maintain book aspect ratio
        return CGSize(width: width, height: height)
    }

    // Center position of the screen
    var screenCenter: CGPoint {
        CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
    }

    // Final reader size (landscape spread that fits within screen)
    var readerSize: CGSize {
        // A two-page spread has roughly 2:1.4 aspect ratio (width:height) = ~1.43 landscape
        let spreadAspectRatio: CGFloat = 2.0 / 1.4

        // Calculate size that fits within screen with padding
        let availableWidth = screenSize.width - 48
        let availableHeight = screenSize.height - 100  // More vertical padding for UI controls

        let widthForHeight = availableHeight * spreadAspectRatio
        let heightForWidth = availableWidth / spreadAspectRatio

        if widthForHeight <= availableWidth {
            // Height-constrained: use full available height
            return CGSize(width: widthForHeight, height: availableHeight)
        } else {
            // Width-constrained: use full available width
            return CGSize(width: availableWidth, height: heightForWidth)
        }
    }

    // Calculate interpolated position
    func interpolatedPosition(from start: CGPoint, to end: CGPoint, progress: CGFloat) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * progress,
            y: start.y + (end.y - start.y) * progress
        )
    }

    // Calculate interpolated size
    func interpolatedSize(from start: CGSize, to end: CGSize, progress: CGFloat) -> CGSize {
        CGSize(
            width: start.width + (end.width - start.width) * progress,
            height: start.height + (end.height - start.height) * progress
        )
    }
}

// MARK: - Preference Key for Book Position

struct BookPositionKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]

    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func trackBookPosition(id: UUID, in coordinateSpace: CoordinateSpace = .global) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: BookPositionKey.self,
                    value: [id: geometry.frame(in: coordinateSpace)]
                )
            }
        )
    }
}

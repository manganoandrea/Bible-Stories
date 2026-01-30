//
//  BookOpeningView.swift
//  BibleStories
//
//  Orchestrates opening and closing book animations using AnimatedBookView.
//

import SwiftUI

struct BookOpeningView: View {
    let book: Book
    @Binding var phase: ContentView.AnimationPhase
    let screenSize: CGSize
    let originalFrame: CGRect
    let onComplete: () -> Void

    @State private var flipAngle: Double = 0
    @State private var coverImage: UIImage?
    @State private var firstPageImage: UIImage?

    // MARK: - Constants

    private let bookSize = CGSize(width: 191, height: 212)
    private let selectedScale: CGFloat = 1.05
    private let centerScale: CGFloat = 1.8
    private let spreadScale: CGFloat = 2.2

    // MARK: - Body

    var body: some View {
        AnimatedBookView(
            coverImage: coverImage,
            firstPageImage: firstPageImage,
            size: currentSize,
            flipAngle: flipAngle,
            showSpread: showSpread
        )
        .scaleEffect(currentScale)
        .position(currentPosition)
        .onChange(of: phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
        .onAppear {
            loadImages()
        }
    }

    // MARK: - Computed Properties

    private var showSpread: Bool {
        switch phase {
        case .revealing, .zooming, .modeSelection, .complete, .closing, .unzooming:
            return true
        default:
            return false
        }
    }

    private var currentSize: CGSize {
        bookSize  // Base size, scaling handled by scaleEffect
    }

    private var currentScale: CGFloat {
        switch phase {
        case .idle:
            return 1.0
        case .selected:
            return selectedScale
        case .moving:
            return centerScale
        case .flipping:
            return centerScale
        case .revealing:
            return spreadScale
        case .zooming, .modeSelection, .complete:
            return screenScale
        case .closing:
            return spreadScale
        case .unzooming:
            return spreadScale
        case .unflipping:
            return centerScale
        case .returning:
            return 1.0
        }
    }

    private var screenScale: CGFloat {
        // Scale to fill screen width with the spread
        let spreadWidth = bookSize.width * 2
        return (screenSize.width * 0.95) / spreadWidth
    }

    private var currentPosition: CGPoint {
        switch phase {
        case .idle, .selected, .returning:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        default:
            return CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        }
    }

    // MARK: - Methods

    private func loadImages() {
        coverImage = UIImage(named: book.coverImage)
        if let firstPage = book.pages.first {
            firstPageImage = UIImage(named: firstPage.imageAsset)
        }
    }

    private func handlePhaseChange(_ newPhase: ContentView.AnimationPhase) {
        switch newPhase {
        // Opening phases
        case .selected:
            // Just scale feedback, no flip
            break

        case .moving:
            // Move to center, no flip yet
            break

        case .flipping:
            withAnimation(.spring(duration: 0.7, bounce: 0.05)) {
                flipAngle = 180
            }

        case .revealing:
            // Spread is visible, prepare for zoom
            break

        case .zooming:
            // Zoom to fullscreen, then complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard phase == .zooming else { return }
                onComplete()
            }

        // Closing phases
        case .closing:
            flipAngle = 180  // Ensure we're at open position

        case .unflipping:
            withAnimation(.spring(duration: 0.7, bounce: 0.05)) {
                flipAngle = 0
            }

        case .returning:
            // Moving back to original position
            break

        case .idle:
            flipAngle = 0

        default:
            break
        }
    }
}

#Preview {
    @Previewable @State var phase: ContentView.AnimationPhase = .idle

    ZStack {
        CelestialVaultBackground()
            .ignoresSafeArea()

        BookOpeningView(
            book: .adamAndEve,
            phase: $phase,
            screenSize: CGSize(width: 1024, height: 768),
            originalFrame: CGRect(x: 200, y: 300, width: 191, height: 212),
            onComplete: {}
        )

        VStack {
            Spacer()
            HStack(spacing: 20) {
                Button("Idle") { phase = .idle }
                Button("Selected") { phase = .selected }
                Button("Moving") { phase = .moving }
                Button("Flipping") { phase = .flipping }
                Button("Revealing") { phase = .revealing }
                Button("Zooming") { phase = .zooming }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

//
//  BookOpeningView.swift
//  BibleStories
//
//  Orchestrates opening and closing book animations with 3D effects.
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

    private var coordinator: TransitionCoordinator {
        TransitionCoordinator(screenSize: screenSize)
    }

    private let baseSpineWidth: CGFloat = 14
    private let bookCoverSize = CGSize(width: 200, height: 280)
    private let bookSelectedScale: CGFloat = 1.05

    var body: some View {
        Book3DView(
            coverImage: coverImage,
            firstPageImage: firstPageImage,
            size: currentSize,
            flipAngle: flipAngle,
            spineWidth: currentSpineWidth
        )
        .position(currentPosition)
        .onChange(of: phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
        .onAppear {
            loadImages()
        }
    }

    // MARK: - Computed Properties

    private var currentSize: CGSize {
        switch phase {
        case .idle, .returning:
            return bookCoverSize
        case .selected:
            return CGSize(
                width: bookCoverSize.width * bookSelectedScale,
                height: bookCoverSize.height * bookSelectedScale
            )
        case .moving, .flipping, .unflipping:
            return coordinator.centeredBookSize
        case .revealing, .complete, .closing:
            return coordinator.readerSize
        }
    }

    private var currentPosition: CGPoint {
        switch phase {
        case .idle, .selected, .returning:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        case .moving, .flipping, .unflipping, .revealing, .complete, .closing:
            return coordinator.screenCenter
        }
    }

    private var currentSpineWidth: CGFloat {
        let scale = currentSize.width / bookCoverSize.width
        return baseSpineWidth * scale
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
        case .flipping:
            withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                flipAngle = 180
            }
        case .revealing:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                guard phase == .revealing else { return }
                onComplete()
            }

        // Closing phases
        case .closing:
            // Book appears at full flip (already open)
            flipAngle = 180
        case .unflipping:
            withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
                flipAngle = 0
            }
        case .returning:
            // Size and position animate via currentSize/currentPosition
            break

        default:
            break
        }
    }
}

#Preview {
    @Previewable @State var phase: ContentView.AnimationPhase = .moving

    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        BookOpeningView(
            book: .adamAndEve,
            phase: $phase,
            screenSize: CGSize(width: 1024, height: 768),
            originalFrame: CGRect(x: 100, y: 200, width: 200, height: 280),
            onComplete: {}
        )
    }
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            phase = .flipping
        }
    }
}

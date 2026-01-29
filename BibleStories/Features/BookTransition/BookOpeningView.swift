//
//  BookOpeningView.swift
//  BibleStories
//
//  Orchestrates opening and closing book animations with 3D effects and spread display.
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
    @State private var leftHalfImage: UIImage?
    @State private var rightHalfImage: UIImage?

    private var coordinator: TransitionCoordinator {
        TransitionCoordinator(screenSize: screenSize)
    }

    private let baseSpineWidth: CGFloat = 18 // Thicker base for more prominent 3D effect
    private let bookCoverSize = CGSize(width: 200, height: 280)
    private let bookSelectedScale: CGFloat = 1.05
    private let zoomScaleFactor: CGFloat = 0.95

    var body: some View {
        Book3DView(
            coverImage: coverImage,
            leftHalfImage: leftHalfImage,
            rightHalfImage: rightHalfImage,
            size: currentSize,
            flipAngle: flipAngle,
            spineWidth: currentSpineWidth,
            showSpread: showSpread
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

    private var showSpread: Bool {
        switch phase {
        case .revealing, .zooming, .modeSelection, .complete, .closing, .unzooming:
            return true
        default:
            return false
        }
    }

    private var zoomScale: CGFloat {
        let targetWidth = screenSize.width * zoomScaleFactor
        return targetWidth / coordinator.readerSize.width
    }

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
        case .revealing, .unzooming:
            return coordinator.readerSize
        case .zooming, .modeSelection, .complete, .closing:
            // Scale up for zoom effect
            return CGSize(
                width: coordinator.readerSize.width * zoomScale,
                height: coordinator.readerSize.height * zoomScale
            )
        }
    }

    private var currentPosition: CGPoint {
        switch phase {
        case .idle, .selected, .returning:
            return CGPoint(x: originalFrame.midX, y: originalFrame.midY)
        case .moving, .flipping, .unflipping, .revealing, .zooming, .modeSelection, .complete, .closing, .unzooming:
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
        if let firstPage = book.pages.first,
           let pageImage = UIImage(named: firstPage.imageAsset) {
            leftHalfImage = pageImage.leftHalf()
            rightHalfImage = pageImage.rightHalf()
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
            // Spread is now visible, wait for zoom phase
            break
        case .zooming:
            // Zoom handled by currentSize, trigger completion after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
                guard phase == .zooming else { return }
                onComplete()
            }

        // Closing phases
        case .unzooming:
            // Library starts returning, book still visible
            break
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

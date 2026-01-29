//
//  ContentView.swift
//  BibleStories
//
//  Root navigation coordinator for the app.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = LibraryViewModel()
    @State private var selectedBook: Book?
    @State private var showingModeSelection = false
    @State private var showingReader = false
    @State private var selectedMode: StoryMode = .listen
    @State private var animationPhase: AnimationPhase = .idle
    @State private var originalBookFrame: CGRect = .zero
    @Namespace private var bookAnimation

    // MARK: - Animation Timing Constants
    private let openingPhase1Delay: Double = 0.2
    private let openingPhase2Delay: Double = 0.6
    private let openingPhase3Delay: Double = 1.2
    private let closingPhase2Delay: Double = 0.3
    private let closingPhase3Delay: Double = 0.9
    private let closingPhase4Delay: Double = 1.3
    private let openingZoomDelay: Double = 1.5
    private let closingUnzoomDelay: Double = 0.1

    enum AnimationPhase: Equatable {
        // Opening phases
        case idle
        case selected
        case moving
        case flipping
        case revealing
        case zooming       // Depth zoom into spread
        case modeSelection // Show mode selection overlay
        case complete      // Reading mode active
        // Closing phases
        case closing
        case unzooming     // Reverse depth zoom
        case unflipping
        case returning
    }

    // MARK: - Library Effect Properties

    private var libraryScale: CGFloat {
        switch animationPhase {
        case .zooming, .modeSelection, .complete, .closing:
            return 0.85
        case .unzooming:
            return 0.925
        default:
            return 1.0
        }
    }

    private var libraryBlur: CGFloat {
        switch animationPhase {
        case .idle:
            return 0
        case .selected, .moving, .flipping, .revealing:
            return 10
        case .zooming, .modeSelection, .complete, .closing:
            return 25
        case .unzooming:
            return 17.5
        case .unflipping, .returning:
            return 10
        }
    }

    private var libraryOpacity: Double {
        switch animationPhase {
        case .zooming, .modeSelection, .complete, .closing:
            return 0.0
        default:
            return 1.0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Library View (background when book is opening)
                LibraryView(
                    viewModel: viewModel,
                    namespace: bookAnimation,
                    onBookTapped: { book, frame in
                        handleBookTap(book, frame: frame)
                    }
                )
                .scaleEffect(libraryScale)
                .blur(radius: libraryBlur)
                .opacity(libraryOpacity)
                .animation(.easeOut(duration: 0.3), value: animationPhase)

                // Book Opening Animation Overlay
                if let book = selectedBook,
                   animationPhase != .idle,
                   animationPhase != .modeSelection,
                   animationPhase != .complete {
                    BookOpeningView(
                        book: book,
                        phase: $animationPhase,
                        screenSize: geometry.size,
                        originalFrame: originalBookFrame,
                        onComplete: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingModeSelection = true
                                animationPhase = .modeSelection
                            }
                        }
                    )
                }

                // Mode Selection Overlay
                if showingModeSelection, let book = selectedBook {
                    StoryModeSelectionView(
                        book: book,
                        onModeSelected: { mode in
                            selectedMode = mode
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingModeSelection = false
                                showingReader = true
                                animationPhase = .complete
                            }
                        },
                        onClose: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingModeSelection = false
                            }
                            closeBook()
                        },
                        onMusicToggle: {
                            viewModel.toggleMusic()
                        },
                        isMusicEnabled: viewModel.isMusicEnabled
                    )
                    .transition(.opacity)
                }

                // Story Reader (full screen when open)
                if showingReader, let book = selectedBook {
                    StoryReaderView(
                        book: book,
                        initialMode: selectedMode,
                        onClose: {
                            closeBook()
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear {
            viewModel.startMusic()
        }
    }

    private func handleBookTap(_ book: Book, frame: CGRect) {
        guard !book.isLocked else { return }
        guard animationPhase == .idle else { return }

        selectedBook = book
        originalBookFrame = frame

        // Fade out library music
        viewModel.fadeOutMusic()

        // Start animation sequence
        withAnimation(.spring(duration: 0.2)) {
            animationPhase = .selected
        }

        // Phase 2: Move to center
        DispatchQueue.main.asyncAfter(deadline: .now() + openingPhase1Delay) {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                animationPhase = .moving
            }
        }

        // Phase 3: Flip
        DispatchQueue.main.asyncAfter(deadline: .now() + openingPhase2Delay) {
            withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                animationPhase = .flipping
            }
        }

        // Phase 4: Reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + openingPhase3Delay) {
            withAnimation(.spring(duration: 0.3)) {
                animationPhase = .revealing
            }
        }

        // Phase 5: Zoom into spread
        DispatchQueue.main.asyncAfter(deadline: .now() + openingZoomDelay) {
            withAnimation(.easeInOut(duration: 0.4)) {
                animationPhase = .zooming
            }
        }
    }

    private func closeBook() {
        // Phase 1: Unzoom - library starts returning
        withAnimation(.easeOut(duration: 0.3)) {
            showingReader = false
            showingModeSelection = false
            animationPhase = .unzooming
        }

        // Phase 2: Closing - book appears at spread
        DispatchQueue.main.asyncAfter(deadline: .now() + closingUnzoomDelay) {
            withAnimation(.easeOut(duration: 0.3)) {
                animationPhase = .closing
            }
        }

        // Phase 3: Unflipping - book cover flips closed
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase2Delay) {
            withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
                animationPhase = .unflipping
            }
        }

        // Phase 4: Returning - book shrinks and moves back
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase3Delay) {
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                animationPhase = .returning
            }
        }

        // Phase 5: Idle - complete
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase4Delay) {
            withAnimation(.easeOut(duration: 0.2)) {
                animationPhase = .idle
                selectedBook = nil
            }
            // Fade in library music
            viewModel.fadeInMusic()
        }
    }
}

#Preview {
    ContentView()
}

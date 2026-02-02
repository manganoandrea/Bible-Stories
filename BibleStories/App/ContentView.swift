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

    // MARK: - Animation Timing Constants (smoother, tighter timing)
    private let selectedDuration: Double = 0.15
    private let movingDelay: Double = 0.15
    private let flippingDelay: Double = 0.5
    private let revealingDelay: Double = 1.2
    private let zoomingDelay: Double = 1.5

    private let closingDelay: Double = 0.1
    private let unflippingDelay: Double = 0.4
    private let returningDelay: Double = 1.1
    private let idleDelay: Double = 1.5

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
                // Home View (main screen)
                HomeView(
                    books: viewModel.books,
                    onBookTapped: { book in
                        handleBookTap(book, frame: .zero)
                    },
                    onUnlockTapped: {
                        // Handle unlock action (e.g., show paywall)
                    },
                    onMusicTapped: {
                        viewModel.toggleMusic()
                    },
                    onSettingsTapped: {
                        // Handle settings action
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

        // Phase 1: Selected - quick scale feedback
        withAnimation(.spring(duration: selectedDuration)) {
            animationPhase = .selected
        }

        // Phase 2: Moving - book moves to center
        DispatchQueue.main.asyncAfter(deadline: .now() + movingDelay) {
            withAnimation(.spring(duration: 0.35, bounce: 0.15)) {
                animationPhase = .moving
            }
        }

        // Phase 3: Flipping - cover flips open
        DispatchQueue.main.asyncAfter(deadline: .now() + flippingDelay) {
            withAnimation(.spring(duration: 0.7, bounce: 0.05)) {
                animationPhase = .flipping
            }
        }

        // Phase 4: Revealing - spread fully visible
        DispatchQueue.main.asyncAfter(deadline: .now() + revealingDelay) {
            withAnimation(.easeOut(duration: 0.3)) {
                animationPhase = .revealing
            }
        }

        // Phase 5: Zooming - spread fills screen
        DispatchQueue.main.asyncAfter(deadline: .now() + zoomingDelay) {
            withAnimation(.easeInOut(duration: 0.4)) {
                animationPhase = .zooming
            }
        }
    }

    private func closeBook() {
        // Phase 1: Unzoom - start scaling down
        withAnimation(.easeOut(duration: 0.3)) {
            showingReader = false
            showingModeSelection = false
            animationPhase = .unzooming
        }

        // Phase 2: Closing - book at spread size
        DispatchQueue.main.asyncAfter(deadline: .now() + closingDelay) {
            withAnimation(.easeOut(duration: 0.25)) {
                animationPhase = .closing
            }
        }

        // Phase 3: Unflipping - cover flips back closed
        DispatchQueue.main.asyncAfter(deadline: .now() + unflippingDelay) {
            withAnimation(.spring(duration: 0.7, bounce: 0.05)) {
                animationPhase = .unflipping
            }
        }

        // Phase 4: Returning - book moves back to grid
        DispatchQueue.main.asyncAfter(deadline: .now() + returningDelay) {
            withAnimation(.spring(duration: 0.35, bounce: 0.1)) {
                animationPhase = .returning
            }
        }

        // Phase 5: Idle - animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + idleDelay) {
            withAnimation(.easeOut(duration: 0.15)) {
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

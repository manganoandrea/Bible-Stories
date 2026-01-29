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
    @State private var showingReader = false
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

    enum AnimationPhase: Equatable {
        // Opening phases
        case idle
        case selected
        case moving
        case flipping
        case revealing
        case complete
        // Closing phases
        case closing
        case unflipping
        case returning
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
                .blur(radius: animationPhase != .idle ? 10 : 0)
                .animation(.easeOut(duration: 0.2), value: animationPhase)

                // Book Opening Animation Overlay
                if let book = selectedBook, animationPhase != .idle {
                    BookOpeningView(
                        book: book,
                        phase: $animationPhase,
                        screenSize: geometry.size,
                        originalFrame: originalBookFrame,
                        onComplete: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showingReader = true
                                animationPhase = .complete
                            }
                        }
                    )
                }

                // Story Reader (full screen when open)
                if showingReader, let book = selectedBook {
                    StoryReaderView(
                        book: book,
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
    }

    private func handleBookTap(_ book: Book, frame: CGRect) {
        guard !book.isLocked else { return }
        guard animationPhase == .idle else { return }

        selectedBook = book
        originalBookFrame = frame

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
    }

    private func closeBook() {
        // Phase 1: Closing - reader fades, book appears
        withAnimation(.easeOut(duration: 0.3)) {
            showingReader = false
            animationPhase = .closing
        }

        // Phase 2: Unflipping - book cover flips closed
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase2Delay) {
            withAnimation(.spring(duration: 0.6, bounce: 0.05)) {
                animationPhase = .unflipping
            }
        }

        // Phase 3: Returning - book shrinks and moves back
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase3Delay) {
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                animationPhase = .returning
            }
        }

        // Phase 4: Idle - complete
        DispatchQueue.main.asyncAfter(deadline: .now() + closingPhase4Delay) {
            withAnimation(.easeOut(duration: 0.2)) {
                animationPhase = .idle
                selectedBook = nil
            }
        }
    }
}

#Preview {
    ContentView()
}

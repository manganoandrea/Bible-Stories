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
    @Namespace private var bookAnimation

    enum AnimationPhase {
        case idle
        case selected
        case moving
        case flipping
        case revealing
        case complete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Library View (background when book is opening)
                LibraryView(
                    viewModel: viewModel,
                    namespace: bookAnimation,
                    onBookTapped: { book in
                        handleBookTap(book)
                    }
                )
                .blur(radius: animationPhase != .idle ? 10 : 0)
                .animation(.easeOut(duration: 0.2), value: animationPhase)

                // Book Opening Animation Overlay
                if let book = selectedBook, animationPhase != .idle && animationPhase != .complete {
                    BookOpeningView(
                        book: book,
                        namespace: bookAnimation,
                        phase: $animationPhase,
                        screenSize: geometry.size,
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

    private func handleBookTap(_ book: Book) {
        guard !book.isLocked else { return }

        selectedBook = book

        // Start animation sequence
        withAnimation(.spring(duration: 0.2)) {
            animationPhase = .selected
        }

        // Phase 2: Move to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                animationPhase = .moving
            }
        }

        // Phase 3: Flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                animationPhase = .flipping
            }
        }

        // Phase 4: Reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(duration: 0.3)) {
                animationPhase = .revealing
            }
        }
    }

    private func closeBook() {
        withAnimation(.spring(duration: 0.4)) {
            showingReader = false
            animationPhase = .idle
            selectedBook = nil
        }
    }
}

#Preview {
    ContentView()
}

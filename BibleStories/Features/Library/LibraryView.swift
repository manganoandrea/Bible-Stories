//
//  LibraryView.swift
//  BibleStories
//
//  Main library grid screen with celestial background.
//

import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel
    let namespace: Namespace.ID
    let selectedBookId: UUID?
    let onBookTapped: (Book, CGRect) -> Void

    var body: some View {
        GeometryReader { geometry in
            // Calculate book dimensions (portrait ratio 191:212)
            let bookHeight = geometry.size.height * 0.42
            let bookWidth = bookHeight * (191.0 / 212.0)  // Maintain aspect ratio

            // Fixed 16px spacing between books
            let spacing: CGFloat = 16

            // Calculate total width needed for 3 books + spacing
            let totalBooksWidth = (bookWidth * 3) + (spacing * 2)
            let horizontalPadding = (geometry.size.width - totalBooksWidth) / 2

            ZStack {
                // Animated background
                CelestialVaultBackground()
                    .ignoresSafeArea()

                // Full screen scroll with header overlay
                ScrollView(.vertical, showsIndicators: false) {
                    // Manual grid layout for precise 16px spacing
                    VStack(spacing: spacing) {
                        ForEach(0..<rowCount(for: viewModel.books.count), id: \.self) { rowIndex in
                            HStack(spacing: spacing) {
                                ForEach(0..<3, id: \.self) { colIndex in
                                    let bookIndex = rowIndex * 3 + colIndex
                                    if bookIndex < viewModel.books.count {
                                        let book = viewModel.books[bookIndex]
                                        BookCoverView(
                                            book: book,
                                            namespace: namespace,
                                            isHidden: book.id == selectedBookId,
                                            bookSize: CGSize(width: bookWidth, height: bookHeight),
                                            onTap: { frame in
                                                onBookTapped(book, frame)
                                            }
                                        )
                                    } else {
                                        // Empty placeholder to maintain grid alignment
                                        Color.clear
                                            .frame(width: bookWidth, height: bookHeight)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 90)
                    .padding(.bottom, 30)
                }

                // Header overlay (fixed at top)
                VStack {
                    headerBar
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                    Spacer()
                }
            }
        }
    }

    private func rowCount(for bookCount: Int) -> Int {
        (bookCount + 2) / 3
    }

    private var headerBar: some View {
        HStack {
            StickerIconButton(
                systemName: "gearshape.fill",
                action: {}
            )

            Spacer()

            StickerIconButton(
                systemName: "envelope.fill",
                action: {}
            )

            StickerIconButton(
                systemName: viewModel.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                action: {
                    viewModel.toggleMusic()
                }
            )
            .padding(.leading, 12)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace

    LibraryView(
        viewModel: LibraryViewModel(),
        namespace: namespace,
        selectedBookId: nil,
        onBookTapped: { _, _ in }
    )
}

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
    let onBookTapped: (Book) -> Void

    var body: some View {
        ZStack {
            // Animated background
            CelestialVaultBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerBar
                    .padding(.horizontal, 32)
                    .padding(.top, 16)

                // Title
                Text("Living Library")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.gold)
                    .shadow(color: AppColors.gold.opacity(0.5), radius: 10)
                    .padding(.top, 16)

                // Book Grid
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(
                        rows: [GridItem(.flexible())],
                        spacing: 32
                    ) {
                        ForEach(viewModel.books) { book in
                            BookCoverView(
                                book: book,
                                namespace: namespace,
                                onTap: {
                                    onBookTapped(book)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 48)
                    .padding(.vertical, 24)
                }
                .frame(maxHeight: .infinity)

                Spacer(minLength: 32)
            }
        }
    }

    private var headerBar: some View {
        HStack {
            // Settings button
            StickerIconButton(
                systemName: "gearshape.fill",
                action: {
                    // Placeholder for settings/parental gate
                }
            )

            Spacer()

            // Mail/Messages button
            StickerIconButton(
                systemName: "envelope.fill",
                action: {
                    // Placeholder for messages
                }
            )

            // Music toggle
            StickerIconButton(
                systemName: viewModel.isMusicPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill",
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
        onBookTapped: { _ in }
    )
}

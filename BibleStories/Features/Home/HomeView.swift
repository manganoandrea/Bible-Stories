//
//  HomeView.swift
//  BibleStories
//
//  Main home screen with cave background, mascot, and book carousel.
//

import SwiftUI

struct HomeView: View {
    let books: [Book]
    let onBookTapped: (Book) -> Void
    let onUnlockTapped: () -> Void
    let onMusicTapped: () -> Void
    let onSettingsTapped: () -> Void

    var body: some View {
        GeometryReader { geo in
            let safeArea = geo.safeAreaInsets

            ZStack {
                // Background - fills entire screen
                Image("cave_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width + safeArea.leading + safeArea.trailing,
                           height: geo.size.height + safeArea.top + safeArea.bottom)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // Content layer
                VStack(spacing: 0) {
                    // Top buttons
                    HStack {
                        Spacer()
                        HStack(spacing: 12) {
                            HomeIconButton(systemName: "music.note", action: onMusicTapped)
                            HomeIconButton(systemName: "gearshape.fill", action: onSettingsTapped)
                        }
                    }
                    .padding(.top, safeArea.top + 16)
                    .padding(.trailing, safeArea.trailing + 24)

                    Spacer()

                    // Mascot and Books row - aligned at bottom
                    HStack(alignment: .bottom, spacing: 16) {
                        // Mascot - Figma: 266x266
                        Group {
                            if let url = Bundle.main.url(forResource: "lion_mascot", withExtension: "mov") {
                                TransparentVideoPlayer(url: url)
                            } else {
                                Text("🦁").font(.system(size: 100))
                            }
                        }
                        .frame(width: 266, height: 266)

                        // Books carousel - Figma: 184x184 books, 8px spacing
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                                    HomeBookCard(
                                        book: book,
                                        color: [AppColors.bookOrange, AppColors.bookPurple, AppColors.bookCyan, AppColors.bookCyan][index % 4],
                                        size: CGSize(width: 184, height: 184),
                                        onTap: { onBookTapped(book) }
                                    )
                                }
                            }
                            .padding(.trailing, safeArea.trailing + 24)
                        }
                    }
                    .padding(.leading, safeArea.leading + 20)
                    .padding(.bottom, 24)

                    // Unlock button - Figma: 212x40, centered
                    StickerButton(action: onUnlockTapped) {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 16))
                            Text("Unlock all books")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 212, height: 40)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [AppColors.unlockButtonOrange, AppColors.unlockButtonOrangeDark], startPoint: .top, endPoint: .bottom))
                                .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        )
                    }
                    .padding(.bottom, safeArea.bottom + 20)
                }
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Home Icon Button

struct HomeIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        StickerButton(action: action) {
            ZStack {
                Circle()
                    .fill(AppColors.homeButtonBlue)
                    .frame(width: 56, height: 56)
                Image(systemName: systemName)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }
            .overlay(Circle().strokeBorder(.white, lineWidth: 2.5))
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    HomeView(
        books: Book.sampleLibrary,
        onBookTapped: { _ in },
        onUnlockTapped: {},
        onMusicTapped: {},
        onSettingsTapped: {}
    )
}

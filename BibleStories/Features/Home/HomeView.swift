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

                // All content in single VStack
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

                    Spacer(minLength: 80)

                    // Mascot and books - bottom aligned (lion standing on ground)
                    HStack(alignment: .bottom, spacing: 24) {
                        // Mascot - 266x266 as per Figma
                        Group {
                            if let url = Bundle.main.url(forResource: "lion_mascot", withExtension: "mov") {
                                TransparentVideoPlayer(url: url)
                            } else {
                                Text("🦁").font(.system(size: 100))
                            }
                        }
                        .frame(width: 266, height: 266)

                        // Books
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                                    HomeBookCard(
                                        book: book,
                                        color: [AppColors.bookOrange, AppColors.bookPurple, AppColors.bookCyan, AppColors.bookCyan][index % 4],
                                        size: CGSize(width: 160, height: 160),
                                        onTap: { onBookTapped(book) }
                                    )
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, safeArea.trailing + 24)
                        }
                    }
                    .padding(.leading, safeArea.leading + 24)
                    .padding(.bottom, 16)

                    // Unlock button at bottom
                    StickerButton(action: onUnlockTapped) {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                            Text("Unlock all books")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [AppColors.unlockButtonOrange, AppColors.unlockButtonOrangeDark], startPoint: .top, endPoint: .bottom))
                                .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        )
                    }
                    .padding(.bottom, safeArea.bottom + 24)
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

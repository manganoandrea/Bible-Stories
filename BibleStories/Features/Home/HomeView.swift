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

                    // Books carousel - independent of mascot
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
                        .padding(.leading, safeArea.leading + 300)
                        .padding(.trailing, safeArea.trailing + 24)
                    }
                    .padding(.bottom, 24)

                    // Unlock button - centered
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
                    .padding(.bottom, safeArea.bottom + 24)
                }

                // Mascot - absolute position using geo coordinates
                Group {
                    if let url = Bundle.main.url(forResource: "lion_mascot", withExtension: "mov") {
                        TransparentVideoPlayer(url: url)
                    } else {
                        Text("🦁").font(.system(size: 100))
                    }
                }
                .frame(width: 266, height: 266)
                .position(
                    x: safeArea.leading + 153, // 20 + 133 (half width)
                    y: geo.size.height - 133 - 30 // Center at 133 (half height) + 30px from bottom
                )
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

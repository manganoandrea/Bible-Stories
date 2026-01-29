//
//  BookCoverView.swift
//  BibleStories
//
//  Individual book tile for the library grid.
//

import SwiftUI

struct BookCoverView: View {
    let book: Book
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        StickerButton(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Book cover image
                coverImage
                    .matchedGeometryEffect(id: "cover-\(book.id)", in: namespace)

                // Lock overlay for locked books
                if book.isLocked {
                    LockOverlay(cornerRadius: 16)
                }

                // Gift badge for mascot rewards
                if book.hasMascotReward && !book.isLocked {
                    GiftBadge(mascotName: book.mascotName, size: 36)
                        .offset(x: 8, y: -8)
                }
            }
            .frame(width: 200, height: 280)
            .stickerBorder(cornerRadius: 16, borderWidth: book.isLocked ? 2 : 3)
            .opacity(book.isLocked ? 0.7 : 1.0)
        }
    }

    @ViewBuilder
    private var coverImage: some View {
        if let uiImage = UIImage(named: book.coverImage) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 280)
                .clipped()
        } else {
            // Placeholder for missing images
            ZStack {
                AppColors.celestialMid

                VStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.gold)

                    Text(book.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
            .frame(width: 200, height: 280)
        }
    }
}

#Preview {
    ZStack {
        CelestialVaultBackground()
            .ignoresSafeArea()

        HStack(spacing: 24) {
            BookCoverView(
                book: .adamAndEve,
                namespace: Namespace().wrappedValue,
                onTap: {}
            )

            BookCoverView(
                book: .noahsArk,
                namespace: Namespace().wrappedValue,
                onTap: {}
            )
        }
    }
}

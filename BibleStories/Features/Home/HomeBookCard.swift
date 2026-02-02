//
//  HomeBookCard.swift
//  BibleStories
//
//  Book card component for the home screen carousel.
//  Displays a stylized book with 3D page effect.
//

import SwiftUI

struct HomeBookCard: View {
    let book: Book
    let color: Color
    let size: CGSize
    let onTap: () -> Void

    @State private var isPressed = false

    // Book structure dimensions
    private let bindingWidth: CGFloat = 8
    private let pageOffset: CGFloat = 4
    private let cornerRadius: CGFloat = 8

    var body: some View {
        StickerButton(action: onTap) {
            ZStack(alignment: .leading) {
                // Back layer (pages showing on right edge)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .frame(width: size.width, height: size.height)

                // Middle layer (white pages)
                Rectangle()
                    .fill(.white)
                    .frame(width: size.width - bindingWidth, height: size.height - 14)
                    .offset(y: 0)

                // Front cover
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color)
                    .frame(width: size.width - bindingWidth - pageOffset, height: size.height)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 2, y: 0)

                // Lock overlay for locked books
                if book.isLocked {
                    lockOverlay
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
    }

    private var lockOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.black.opacity(0.4))
                .frame(width: size.width - bindingWidth - pageOffset, height: size.height)

            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Preview

#Preview(traits: .landscapeLeft) {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        HStack(spacing: 16) {
            HomeBookCard(
                book: Book.adamAndEve,
                color: AppColors.bookOrange,
                size: CGSize(width: 184, height: 184),
                onTap: {}
            )

            HomeBookCard(
                book: Book.noahsArk,
                color: AppColors.bookPurple,
                size: CGSize(width: 184, height: 184),
                onTap: {}
            )

            HomeBookCard(
                book: Book.davidAndGoliath,
                color: AppColors.bookCyan,
                size: CGSize(width: 184, height: 184),
                onTap: {}
            )
        }
        .padding()
    }
}

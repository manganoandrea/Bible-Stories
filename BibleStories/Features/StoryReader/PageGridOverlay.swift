//
//  PageGridOverlay.swift
//  BibleStories
//
//  Page grid overlay for quick navigation between story pages.
//

import SwiftUI

struct PageGridOverlay: View {
    let book: Book
    let currentPage: Int
    let onPageSelected: (Int) -> Void
    let onClose: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with close button
                headerBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                // Page grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(book.pages.enumerated()), id: \.element.id) { index, page in
                            PageThumbnailView(
                                page: page,
                                pageNumber: index + 1,
                                isSelected: index == currentPage,
                                onTap: {
                                    onPageSelected(index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var headerBar: some View {
        HStack {
            // Close button
            StickerIconButton(
                systemName: "xmark",
                action: onClose,
                size: 50,
                iconSize: 22
            )

            Spacer()

            // Title
            Text("Contents")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            // Spacer for balance
            Color.clear
                .frame(width: 50, height: 50)
        }
    }
}

// MARK: - Page Thumbnail

struct PageThumbnailView: View {
    let page: StoryPage
    let pageNumber: Int
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            triggerHaptic()
            onTap()
        }) {
            ZStack(alignment: .topLeading) {
                // Page image
                thumbnailImage
                    .aspectRatio(16/10, contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                // Selection border
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white, lineWidth: 3)
                }

                // Page number badge
                pageNumberBadge
            }
        }
        .buttonStyle(ThumbnailButtonStyle(isPressed: $isPressed))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(duration: 0.2), value: isPressed)
    }

    @ViewBuilder
    private var thumbnailImage: some View {
        if let uiImage = UIImage(named: page.imageAsset) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
                .fill(AppColors.celestialMid)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.textSecondary)
                )
        }
    }

    private var pageNumberBadge: some View {
        // Bookmark-style badge
        ZStack {
            // Bookmark shape
            BookmarkShape()
                .fill(Color.white)
                .frame(width: 32, height: 40)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)

            // Page number
            Text("\(pageNumber)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.celestialDeep)
                .offset(y: -4)
        }
        .offset(x: 8, y: 0)
    }

    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Bookmark Shape

struct BookmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10))

        // Bottom point
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 20))

        // Left edge to bottom point
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 10))

        // Close path
        path.closeSubpath()

        return path
    }
}

// MARK: - Button Style

private struct ThumbnailButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Preview

#Preview {
    PageGridOverlay(
        book: .adamAndEve,
        currentPage: 2,
        onPageSelected: { page in print("Selected page \(page)") },
        onClose: { print("Close") }
    )
}

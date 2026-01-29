//
//  BookOpeningView.swift
//  BibleStories
//
//  Orchestrates the 4-phase book opening animation.
//

import SwiftUI

struct BookOpeningView: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var phase: ContentView.AnimationPhase
    let screenSize: CGSize
    let onComplete: () -> Void

    @State private var flipAngle: Double = 0
    @State private var showFirstPage: Bool = false

    private var coordinator: TransitionCoordinator {
        TransitionCoordinator(screenSize: screenSize)
    }

    var body: some View {
        ZStack {
            // First page preview (revealed during flip)
            if showFirstPage, let firstPage = book.pages.first {
                firstPagePreview(page: firstPage)
                    .opacity(flipAngle > 90 ? 1 : 0)
            }

            // Book cover (flips open)
            bookCover
                .book3DFlip(angle: -flipAngle, perspective: 0.5, anchor: .leading)
                .opacity(flipAngle < 170 ? 1 : 0)
        }
        .frame(width: currentSize.width, height: currentSize.height)
        .position(coordinator.screenCenter)
        .onChange(of: phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
    }

    private var currentSize: CGSize {
        switch phase {
        case .idle:
            return CGSize(width: 200, height: 280)
        case .selected:
            return CGSize(width: 210, height: 294)
        case .moving, .flipping:
            return coordinator.centeredBookSize
        case .revealing, .complete:
            return coordinator.readerSize
        }
    }

    @ViewBuilder
    private var bookCover: some View {
        if let uiImage = UIImage(named: book.coverImage) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: currentSize.width, height: currentSize.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
                .shadow(color: AppColors.stickerShadow, radius: 12, x: 0, y: 6)
        } else {
            placeholderCover
        }
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.celestialMid)

            VStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.gold)

                Text(book.title)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .frame(width: currentSize.width, height: currentSize.height)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
        )
        .shadow(color: AppColors.stickerShadow, radius: 12, x: 0, y: 6)
    }

    @ViewBuilder
    private func firstPagePreview(page: StoryPage) -> some View {
        if let uiImage = UIImage(named: page.imageAsset) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: currentSize.width, height: currentSize.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(AppColors.stickerBorder, lineWidth: 3)
                )
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.celestialLight)
                .frame(width: currentSize.width, height: currentSize.height)
        }
    }

    private func handlePhaseChange(_ newPhase: ContentView.AnimationPhase) {
        switch newPhase {
        case .flipping:
            showFirstPage = true
            withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                flipAngle = 180
            }
        case .revealing:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        default:
            break
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var phase: ContentView.AnimationPhase = .moving

    ZStack {
        AppColors.celestialGradient
            .ignoresSafeArea()

        BookOpeningView(
            book: .adamAndEve,
            namespace: namespace,
            phase: $phase,
            screenSize: CGSize(width: 1024, height: 768),
            onComplete: {}
        )
    }
    .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            phase = .flipping
        }
    }
}

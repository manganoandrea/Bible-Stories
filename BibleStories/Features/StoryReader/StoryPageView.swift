//
//  StoryPageView.swift
//  BibleStories
//
//  Single illustration page with text overlay.
//

import SwiftUI

struct StoryPageView: View {
    let page: StoryPage
    let pageNumber: Int
    let totalPages: Int
    let isPlaying: Bool
    let onTapToPlay: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-bleed illustration
                pageImage(size: geometry.size)

                // Text overlay at bottom
                VStack {
                    Spacer()

                    textOverlay
                        .frame(maxWidth: geometry.size.width * 0.85)
                        .padding(.bottom, 80)
                }

                // Play indicator
                if !isPlaying {
                    playIndicator
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTapToPlay()
        }
    }

    @ViewBuilder
    private func pageImage(size: CGSize) -> some View {
        if let uiImage = UIImage(named: page.imageAsset) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
        } else {
            // Placeholder
            ZStack {
                AppColors.celestialMid

                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 64))
                        .foregroundStyle(AppColors.textSecondary)

                    Text("Page \(pageNumber + 1)")
                        .font(.title2)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var textOverlay: some View {
        VStack(spacing: 8) {
            Text(page.narrationText)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(AppColors.stickerBorder.opacity(0.5), lineWidth: 2)
                )
        )
        .shadow(color: AppColors.stickerShadow, radius: 10, x: 0, y: 4)
    }

    private var playIndicator: some View {
        VStack {
            HStack {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppColors.celestialDeep.opacity(0.8))
                        .frame(width: 50, height: 50)

                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.gold)
                }
                .overlay(
                    Circle()
                        .strokeBorder(AppColors.gold.opacity(0.5), lineWidth: 2)
                )
                .padding(.trailing, 24)
                .padding(.top, 24)
            }

            Spacer()
        }
    }
}

#Preview {
    StoryPageView(
        page: StoryPage(
            imageAsset: "page_00",
            narrationText: "In the beginning, God created the heavens and the earth.",
            audioFile: "page_00_audio"
        ),
        pageNumber: 0,
        totalPages: 12,
        isPlaying: false,
        onTapToPlay: {}
    )
}

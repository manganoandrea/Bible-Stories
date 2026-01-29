//
//  StoryReaderView.swift
//  BibleStories
//
//  Page container for reading stories with audio narration.
//

import SwiftUI

struct StoryReaderView: View {
    let book: Book
    let onClose: () -> Void

    @State private var currentPage: Int = 0
    @State private var audioPlayer = AudioNarrationPlayer()
    @State private var autoAdvance: Bool = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Page content with swipe gesture
                TabView(selection: $currentPage) {
                    ForEach(Array(book.pages.enumerated()), id: \.element.id) { index, page in
                        StoryPageView(
                            page: page,
                            pageNumber: index,
                            totalPages: book.pages.count,
                            isPlaying: audioPlayer.isPlaying && currentPage == index,
                            onTapToPlay: {
                                audioPlayer.togglePlayback()
                            }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                // UI Overlay
                VStack {
                    // Top bar
                    topBar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    Spacer()

                    // Bottom controls
                    bottomControls
                        .padding(.bottom, 24)
                }
            }
        }
        .onChange(of: currentPage) { _, newPage in
            loadAudioForPage(newPage)
        }
        .onAppear {
            setupAudioPlayer()
            loadAudioForPage(0)
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }

    private var topBar: some View {
        HStack {
            // Close button
            StickerIconButton(
                systemName: "xmark",
                action: onClose,
                size: 44,
                iconSize: 18
            )

            Spacer()

            // Book title
            Text(book.title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(AppColors.celestialDeep.opacity(0.7))
                        .overlay(
                            Capsule()
                                .strokeBorder(AppColors.stickerBorder.opacity(0.5), lineWidth: 2)
                        )
                )

            Spacer()

            // Auto-advance toggle
            StickerIconButton(
                systemName: autoAdvance ? "forward.fill" : "forward",
                action: { autoAdvance.toggle() },
                size: 44,
                iconSize: 18,
                backgroundColor: autoAdvance ? AppColors.gold.opacity(0.3) : AppColors.celestialMid
            )
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            // Page indicator
            PageIndicator(
                currentPage: currentPage,
                totalPages: book.pages.count
            )

            // Navigation buttons
            HStack(spacing: 32) {
                // Previous page
                StickerIconButton(
                    systemName: "chevron.left",
                    action: { goToPreviousPage() },
                    size: 50,
                    iconSize: 20
                )
                .opacity(currentPage > 0 ? 1 : 0.3)
                .disabled(currentPage == 0)

                // Play/Pause
                StickerIconButton(
                    systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill",
                    action: { audioPlayer.togglePlayback() },
                    size: 60,
                    iconSize: 24,
                    backgroundColor: AppColors.gold.opacity(0.8)
                )

                // Next page
                StickerIconButton(
                    systemName: "chevron.right",
                    action: { goToNextPage() },
                    size: 50,
                    iconSize: 20
                )
                .opacity(currentPage < book.pages.count - 1 ? 1 : 0.3)
                .disabled(currentPage == book.pages.count - 1)
            }
        }
    }

    private func setupAudioPlayer() {
        audioPlayer.onPlaybackComplete = { [self] in
            if autoAdvance && currentPage < book.pages.count - 1 {
                withAnimation(.spring(duration: 0.3)) {
                    currentPage += 1
                }
            }
        }
    }

    private func loadAudioForPage(_ pageIndex: Int) {
        audioPlayer.stop()

        guard pageIndex < book.pages.count else { return }

        let page = book.pages[pageIndex]
        if let audioFile = page.audioFile {
            audioPlayer.load(audioFile: audioFile)

            // Preload next page audio
            if pageIndex + 1 < book.pages.count,
               let nextAudio = book.pages[pageIndex + 1].audioFile {
                audioPlayer.preload(audioFile: nextAudio)
            }
        }
    }

    private func goToPreviousPage() {
        guard currentPage > 0 else { return }
        withAnimation(.spring(duration: 0.3)) {
            currentPage -= 1
        }
        triggerHaptic()
    }

    private func goToNextPage() {
        guard currentPage < book.pages.count - 1 else { return }
        withAnimation(.spring(duration: 0.3)) {
            currentPage += 1
        }
        triggerHaptic()
    }

    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

#Preview {
    StoryReaderView(
        book: .adamAndEve,
        onClose: {}
    )
}

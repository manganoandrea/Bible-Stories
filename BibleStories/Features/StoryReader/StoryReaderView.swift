//
//  StoryReaderView.swift
//  BibleStories
//
//  Page container for reading stories with audio narration.
//

import SwiftUI

struct StoryReaderView: View {
    let book: Book
    let initialMode: StoryMode
    let onClose: () -> Void

    @State private var currentPage: Int = 0
    @State private var audioPlayer = AudioNarrationPlayer()
    @State private var currentMode: StoryMode
    @State private var isUIHidden: Bool = false
    @State private var showingPageGrid: Bool = false

    init(book: Book, initialMode: StoryMode = .listen, onClose: @escaping () -> Void) {
        self.book = book
        self.initialMode = initialMode
        self.onClose = onClose
        self._currentMode = State(initialValue: initialMode)
    }

    private var isListenMode: Bool {
        currentMode == .listen
    }

    var body: some View {
        ZStack {
            // Solid background to prevent any black showing through
            Color.black
                .ignoresSafeArea()

            // Page content with swipe gesture
            TabView(selection: $currentPage) {
                ForEach(Array(book.pages.enumerated()), id: \.element.id) { index, page in
                    StoryPageView(
                        page: page,
                        pageNumber: index,
                        totalPages: book.pages.count,
                        isPlaying: audioPlayer.isPlaying && currentPage == index,
                        showFrame: !isUIHidden,
                        onTapToPlay: {
                            toggleUIVisibility()
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()

            // UI Overlay (hidden in immersive mode)
            if !isUIHidden {
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
                .transition(.opacity)
            }

            // Audio playing indicator (visible even when UI hidden)
            if isUIHidden && audioPlayer.isPlaying {
                audioPlayingIndicator
            }

            // Page Grid Overlay
            if showingPageGrid {
                PageGridOverlay(
                    book: book,
                    currentPage: currentPage,
                    onPageSelected: { page in
                        currentPage = page
                        withAnimation(.easeOut(duration: 0.3)) {
                            showingPageGrid = false
                        }
                    },
                    onClose: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showingPageGrid = false
                        }
                    }
                )
                .transition(.opacity)
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

    // MARK: - UI Visibility

    private func toggleUIVisibility() {
        withAnimation(.easeOut(duration: 0.3)) {
            isUIHidden.toggle()
        }
        triggerHaptic()
    }

    private var audioPlayingIndicator: some View {
        VStack {
            HStack {
                Spacer()
                // Pulsing audio indicator
                Circle()
                    .fill(AppColors.gold.opacity(0.8))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(AppColors.gold, lineWidth: 2)
                            .scaleEffect(1.5)
                            .opacity(0)
                            .animation(
                                .easeOut(duration: 1.0)
                                .repeatForever(autoreverses: false),
                                value: audioPlayer.isPlaying
                            )
                    )
                    .padding(.trailing, 20)
                    .padding(.top, 20)
            }
            Spacer()
        }
    }

    private var topBar: some View {
        HStack {
            // Home/Close button
            StickerIconButton(
                systemName: "house.fill",
                action: onClose,
                size: 44,
                iconSize: 18
            )

            Spacer()

            // Contents button (center)
            StickerIconButton(
                systemName: "square.grid.2x2.fill",
                action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showingPageGrid = true
                    }
                },
                size: 44,
                iconSize: 18
            )

            Spacer()

            // Mode toggle (Read/Listen)
            StickerIconButton(
                systemName: currentMode.icon,
                action: { toggleMode() },
                size: 44,
                iconSize: 18,
                backgroundColor: isListenMode ? AppColors.gold.opacity(0.3) : AppColors.celestialMid
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
            if isListenMode && currentPage < book.pages.count - 1 {
                withAnimation(.spring(duration: 0.3)) {
                    currentPage += 1
                }
            }
        }
    }

    private func toggleMode() {
        currentMode = isListenMode ? .read : .listen

        // If switching to Listen mode, start playing current page audio
        if isListenMode {
            if let audioFile = book.pages[currentPage].audioFile {
                audioPlayer.load(audioFile: audioFile)
                audioPlayer.play()
            }
        } else {
            // If switching to Read mode, stop audio
            audioPlayer.stop()
        }
    }

    private func loadAudioForPage(_ pageIndex: Int) {
        audioPlayer.stop()

        guard pageIndex < book.pages.count else { return }

        let page = book.pages[pageIndex]
        if let audioFile = page.audioFile {
            audioPlayer.load(audioFile: audioFile)

            // Auto-play in Listen mode
            if isListenMode {
                audioPlayer.play()
            }

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
        initialMode: .listen,
        onClose: {}
    )
}

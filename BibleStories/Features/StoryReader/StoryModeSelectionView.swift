//
//  StoryModeSelectionView.swift
//  BibleStories
//
//  Mode selection overlay with Read and Listen options.
//

import SwiftUI

enum StoryMode: String, CaseIterable {
    case read = "Read"
    case listen = "Listen"

    var icon: String {
        switch self {
        case .read: return "book.fill"
        case .listen: return "headphones"
        }
    }
}

struct StoryModeSelectionView: View {
    let book: Book
    let onModeSelected: (StoryMode) -> Void
    let onClose: () -> Void
    let onMusicToggle: () -> Void
    let isMusicEnabled: Bool

    @State private var buttonsVisible = false

    var body: some View {
        ZStack {
            // Dimmed first page as backdrop
            firstPageBackdrop

            // Dark overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            // Content
            VStack {
                // Top bar
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                // Mode buttons
                modeButtons
                    .opacity(buttonsVisible ? 1 : 0)
                    .offset(y: buttonsVisible ? 0 : 20)

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.4).delay(0.2)) {
                buttonsVisible = true
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var firstPageBackdrop: some View {
        if let firstPage = book.pages.first,
           let uiImage = UIImage(named: firstPage.imageAsset) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else if let uiImage = UIImage(named: book.coverImage) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            AppColors.celestialDeep
                .ignoresSafeArea()
        }
    }

    private var topBar: some View {
        HStack {
            // Home/Close button
            StickerIconButton(
                systemName: "house.fill",
                action: onClose,
                size: 50,
                iconSize: 22
            )

            Spacer()

            // Music toggle
            StickerIconButton(
                systemName: isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                action: onMusicToggle,
                size: 50,
                iconSize: 22
            )
        }
    }

    private var modeButtons: some View {
        VStack(spacing: 16) {
            ForEach(StoryMode.allCases, id: \.self) { mode in
                ModeButton(mode: mode) {
                    onModeSelected(mode)
                }
            }
        }
    }
}

// MARK: - Mode Button

private struct ModeButton: View {
    let mode: StoryMode
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(mode.rawValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 48)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ModeButtonStyle(isPressed: $isPressed))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(duration: 0.2), value: isPressed)
    }

    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

private struct ModeButtonStyle: ButtonStyle {
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
    StoryModeSelectionView(
        book: .adamAndEve,
        onModeSelected: { mode in print("Selected: \(mode)") },
        onClose: { print("Close") },
        onMusicToggle: { print("Toggle music") },
        isMusicEnabled: true
    )
}

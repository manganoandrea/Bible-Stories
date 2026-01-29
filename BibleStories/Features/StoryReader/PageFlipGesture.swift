//
//  PageFlipGesture.swift
//  BibleStories
//
//  Swipe navigation gesture handler for page turns.
//

import SwiftUI

struct PageFlipGesture: ViewModifier {
    @Binding var currentPage: Int
    let totalPages: Int
    let onPageChange: ((Int) -> Void)?

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    private let threshold: CGFloat = 50
    private let maxDragDistance: CGFloat = 200

    func body(content: Content) -> some View {
        content
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        isDragging = true
                        // Limit drag distance with rubber band effect
                        let translation = value.translation.width

                        // Check boundaries
                        if (currentPage == 0 && translation > 0) ||
                           (currentPage == totalPages - 1 && translation < 0) {
                            // Rubber band effect at boundaries
                            dragOffset = translation * 0.3
                        } else {
                            dragOffset = min(max(translation, -maxDragDistance), maxDragDistance)
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        let translation = value.translation.width

                        withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                            if translation < -threshold && currentPage < totalPages - 1 {
                                // Swipe left - next page
                                currentPage += 1
                                onPageChange?(currentPage)
                                triggerHaptic()
                            } else if translation > threshold && currentPage > 0 {
                                // Swipe right - previous page
                                currentPage -= 1
                                onPageChange?(currentPage)
                                triggerHaptic()
                            }
                            dragOffset = 0
                        }
                    }
            )
    }

    private func triggerHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

extension View {
    func pageFlipGesture(
        currentPage: Binding<Int>,
        totalPages: Int,
        onPageChange: ((Int) -> Void)? = nil
    ) -> some View {
        modifier(PageFlipGesture(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChange: onPageChange
        ))
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? AppColors.gold : AppColors.textSecondary)
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(duration: 0.2), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppColors.celestialDeep.opacity(0.7))
        )
    }
}

#Preview {
    @Previewable @State var page = 2

    VStack {
        Spacer()

        PageIndicator(currentPage: page, totalPages: 12)

        Spacer()

        HStack {
            Button("Prev") { if page > 0 { page -= 1 } }
            Button("Next") { if page < 11 { page += 1 } }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.celestialGradient)
}

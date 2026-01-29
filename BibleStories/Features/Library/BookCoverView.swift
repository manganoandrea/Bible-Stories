//
//  BookCoverView.swift
//  BibleStories
//
//  Individual book tile for the library grid using 3D physical book appearance.
//

import SwiftUI

struct BookCoverView: View {
    let book: Book
    let namespace: Namespace.ID
    let isHidden: Bool
    let bookSize: CGSize
    let onTap: (CGRect) -> Void

    init(
        book: Book,
        namespace: Namespace.ID,
        isHidden: Bool = false,
        bookSize: CGSize = CGSize(width: 191, height: 212),
        onTap: @escaping (CGRect) -> Void
    ) {
        self.book = book
        self.namespace = namespace
        self.isHidden = isHidden
        self.bookSize = bookSize
        self.onTap = onTap
    }

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                guard !book.isLocked else { return }
                let frame = geometry.frame(in: .global)
                onTap(frame)
            }) {
                PhysicalBookView(
                    coverImage: UIImage(named: book.coverImage),
                    title: book.title,
                    isLocked: book.isLocked,
                    size: bookSize
                )
            }
            .buttonStyle(BookButtonStyle())
            .opacity(isHidden ? 0 : 1)
        }
        .frame(width: bookSize.width, height: bookSize.height)
    }
}

// MARK: - Book Button Style

private struct BookButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        CelestialVaultBackground()
            .ignoresSafeArea()

        HStack(spacing: 16) {
            BookCoverView(
                book: .adamAndEve,
                namespace: Namespace().wrappedValue,
                bookSize: CGSize(width: 191, height: 212),
                onTap: { _ in }
            )

            BookCoverView(
                book: .noahsArk,
                namespace: Namespace().wrappedValue,
                bookSize: CGSize(width: 191, height: 212),
                onTap: { _ in }
            )
        }
    }
}

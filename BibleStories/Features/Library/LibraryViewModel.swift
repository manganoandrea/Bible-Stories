//
//  LibraryViewModel.swift
//  BibleStories
//
//  Book data and state management for the library.
//

import SwiftUI
import Observation

@Observable
final class LibraryViewModel {
    var books: [Book]
    var selectedBookID: UUID?
    var isMusicPlaying: Bool = true

    init(books: [Book] = Book.sampleLibrary) {
        self.books = books
    }

    var selectedBook: Book? {
        guard let id = selectedBookID else { return nil }
        return books.first { $0.id == id }
    }

    func selectBook(_ book: Book) {
        guard !book.isLocked else { return }
        selectedBookID = book.id
    }

    func clearSelection() {
        selectedBookID = nil
    }

    func unlockBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = Book(
                id: book.id,
                title: book.title,
                coverImage: book.coverImage,
                pages: book.pages,
                isLocked: false,
                hasMascotReward: book.hasMascotReward,
                mascotName: book.mascotName
            )
        }
    }

    func toggleMusic() {
        isMusicPlaying.toggle()
    }
}

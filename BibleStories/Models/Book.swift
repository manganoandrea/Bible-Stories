//
//  Book.swift
//  BibleStories
//
//  Book metadata model.
//

import Foundation

struct Book: Identifiable, Equatable {
    let id: UUID
    let title: String
    let coverImage: String
    let pages: [StoryPage]
    let isLocked: Bool
    let hasMascotReward: Bool
    let mascotName: String?

    init(
        id: UUID = UUID(),
        title: String,
        coverImage: String,
        pages: [StoryPage],
        isLocked: Bool = false,
        hasMascotReward: Bool = false,
        mascotName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.coverImage = coverImage
        self.pages = pages
        self.isLocked = isLocked
        self.hasMascotReward = hasMascotReward
        self.mascotName = mascotName
    }

    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data

extension Book {
    static let adamAndEve = Book(
        title: "Adam and Eve",
        coverImage: "adam_eve_cover",
        pages: [
            StoryPage(
                imageAsset: "page_00",
                narrationText: "In the beginning, God created the heavens and the earth.",
                audioFile: "page_00_audio"
            ),
            StoryPage(
                imageAsset: "page_01",
                narrationText: "God created Adam from the dust of the ground and breathed life into him.",
                audioFile: "page_01_audio"
            ),
            StoryPage(
                imageAsset: "page_02",
                narrationText: "God planted a beautiful garden in Eden for Adam to live in.",
                audioFile: "page_02_audio"
            ),
            StoryPage(
                imageAsset: "page_03",
                narrationText: "God created Eve to be Adam's companion and helper.",
                audioFile: "page_03_audio"
            ),
            StoryPage(
                imageAsset: "page_04",
                narrationText: "Adam and Eve lived happily together in the Garden of Eden.",
                audioFile: "page_04_audio"
            ),
            StoryPage(
                imageAsset: "page_05",
                narrationText: "God told them they could eat from any tree except the Tree of Knowledge.",
                audioFile: "page_05_audio"
            ),
            StoryPage(
                imageAsset: "page_06",
                narrationText: "A cunning serpent tempted Eve to eat the forbidden fruit.",
                audioFile: "page_06_audio"
            ),
            StoryPage(
                imageAsset: "page_07",
                narrationText: "Eve ate the fruit and shared it with Adam.",
                audioFile: "page_07_audio"
            ),
            StoryPage(
                imageAsset: "page_08",
                narrationText: "They realized they had disobeyed God and felt ashamed.",
                audioFile: "page_08_audio"
            ),
            StoryPage(
                imageAsset: "page_09",
                narrationText: "God called out to Adam and Eve in the garden.",
                audioFile: "page_09_audio"
            ),
            StoryPage(
                imageAsset: "page_10",
                narrationText: "God told them they must leave the Garden of Eden.",
                audioFile: "page_10_audio"
            ),
            StoryPage(
                imageAsset: "page_11",
                narrationText: "Though they left the garden, God still loved them and promised to care for them always.",
                audioFile: "page_11_audio"
            )
        ],
        isLocked: false,
        hasMascotReward: true,
        mascotName: "Dove"
    )

    static let noahsArk = Book(
        title: "Noah's Ark",
        coverImage: "noahs_ark_cover",
        pages: [],
        isLocked: true,
        hasMascotReward: true,
        mascotName: "Lion"
    )

    static let davidAndGoliath = Book(
        title: "David and Goliath",
        coverImage: "david_goliath_cover",
        pages: [],
        isLocked: true,
        hasMascotReward: true,
        mascotName: "Sheep"
    )

    static let danielAndTheLions = Book(
        title: "Daniel and the Lions",
        coverImage: "daniel_lions_cover",
        pages: [],
        isLocked: true,
        hasMascotReward: true,
        mascotName: "Lion"
    )

    static let jonah = Book(
        title: "Jonah and the Whale",
        coverImage: "jonah_cover",
        pages: [],
        isLocked: true,
        hasMascotReward: true,
        mascotName: "Whale"
    )

    static let sampleLibrary: [Book] = [
        .adamAndEve,
        .noahsArk,
        .davidAndGoliath,
        .danielAndTheLions,
        .jonah
    ]
}

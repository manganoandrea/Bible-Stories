//
//  StoryPage.swift
//  BibleStories
//
//  Page content model for story pages.
//

import Foundation

struct StoryPage: Identifiable, Equatable {
    let id: UUID
    let imageAsset: String
    let narrationText: String
    let audioFile: String?

    init(
        id: UUID = UUID(),
        imageAsset: String,
        narrationText: String,
        audioFile: String? = nil
    ) {
        self.id = id
        self.imageAsset = imageAsset
        self.narrationText = narrationText
        self.audioFile = audioFile
    }

    static func == (lhs: StoryPage, rhs: StoryPage) -> Bool {
        lhs.id == rhs.id
    }
}

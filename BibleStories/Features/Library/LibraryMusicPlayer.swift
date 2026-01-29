//
//  LibraryMusicPlayer.swift
//  BibleStories
//
//  Background music player for the library with fade transitions.
//

import AVFoundation
import SwiftUI

@Observable
final class LibraryMusicPlayer {
    private var audioPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?

    private(set) var isPlaying: Bool = false

    private let fadeDuration: TimeInterval = 0.5
    private let fadeSteps: Int = 20
    private let userDefaultsKey = "libraryMusicEnabled"

    var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: userDefaultsKey)
            if isMusicEnabled {
                play()
            } else {
                stop()
            }
        }
    }

    init() {
        self.isMusicEnabled = UserDefaults.standard.object(forKey: userDefaultsKey) as? Bool ?? true
        setupAudioSession()
        loadAudio()
    }

    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }

    private func loadAudio() {
        guard let url = Bundle.main.url(forResource: "Garden_of_Joy", withExtension: "wav") else {
            print("Library music file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to load library music: \(error)")
        }
    }

    // MARK: - Playback Control

    func play() {
        guard isMusicEnabled, let player = audioPlayer else { return }
        player.volume = 1.0
        player.play()
        isPlaying = true
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func toggle() {
        isMusicEnabled.toggle()
    }

    // MARK: - Fade Transitions

    func fadeOut(completion: (() -> Void)? = nil) {
        guard let player = audioPlayer, player.isPlaying else {
            completion?()
            return
        }

        cancelFade()

        let stepDuration = fadeDuration / Double(fadeSteps)
        let volumeStep = player.volume / Float(fadeSteps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }

            currentStep += 1
            player.volume = max(0, player.volume - volumeStep)

            if currentStep >= self.fadeSteps {
                timer.invalidate()
                player.pause()
                self.isPlaying = false
                completion?()
            }
        }
    }

    func fadeIn(completion: (() -> Void)? = nil) {
        guard isMusicEnabled, let player = audioPlayer else {
            completion?()
            return
        }

        cancelFade()

        player.volume = 0
        player.play()
        isPlaying = true

        let stepDuration = fadeDuration / Double(fadeSteps)
        let volumeStep: Float = 1.0 / Float(fadeSteps)
        var currentStep = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }

            currentStep += 1
            player.volume = min(1.0, player.volume + volumeStep)

            if currentStep >= self.fadeSteps {
                timer.invalidate()
                completion?()
            }
        }
    }

    private func cancelFade() {
        fadeTimer?.invalidate()
        fadeTimer = nil
    }

    deinit {
        cancelFade()
        audioPlayer?.stop()
    }
}

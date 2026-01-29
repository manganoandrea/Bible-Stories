//
//  AudioNarrationPlayer.swift
//  BibleStories
//
//  AVAudioPlayer wrapper for narration playback.
//

import AVFoundation
import SwiftUI
import Observation

@Observable
final class AudioNarrationPlayer: NSObject {
    private var audioPlayer: AVAudioPlayer?
    private var preloadedPlayer: AVAudioPlayer?

    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var onPlaybackComplete: (() -> Void)?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    func load(audioFile: String) {
        guard let url = Bundle.main.url(forResource: audioFile, withExtension: "mp3") ??
              Bundle.main.url(forResource: audioFile, withExtension: "m4a") ??
              Bundle.main.url(forResource: audioFile, withExtension: "wav") else {
            print("Audio file not found: \(audioFile)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    func preload(audioFile: String) {
        guard let url = Bundle.main.url(forResource: audioFile, withExtension: "mp3") ??
              Bundle.main.url(forResource: audioFile, withExtension: "m4a") ??
              Bundle.main.url(forResource: audioFile, withExtension: "wav") else {
            return
        }

        do {
            preloadedPlayer = try AVAudioPlayer(contentsOf: url)
            preloadedPlayer?.prepareToPlay()
        } catch {
            print("Failed to preload audio: \(error)")
        }
    }

    func usePreloaded() {
        audioPlayer = preloadedPlayer
        audioPlayer?.delegate = self
        duration = audioPlayer?.duration ?? 0
        preloadedPlayer = nil
    }

    func play() {
        audioPlayer?.play()
        isPlaying = true
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    func updateCurrentTime() {
        currentTime = audioPlayer?.currentTime ?? 0
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioNarrationPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        onPlaybackComplete?()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown")")
        isPlaying = false
    }
}

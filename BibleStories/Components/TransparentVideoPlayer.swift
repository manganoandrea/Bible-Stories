//
//  TransparentVideoPlayer.swift
//  BibleStories
//
//  Plays HEVC videos with alpha channel transparency.
//

import SwiftUI
import AVFoundation
import AVKit

// MARK: - UIKit Video View

class TransparentVideoUIView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: NSObjectProtocol?

    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    private var avPlayerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    func play(url: URL) {
        stop()

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        avPlayerLayer.player = player
        avPlayerLayer.videoGravity = .resizeAspect
        avPlayerLayer.pixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        // Loop playback
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }

        player?.play()
    }

    func stop() {
        player?.pause()
        player = nil
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
            loopObserver = nil
        }
    }

    deinit {
        stop()
    }
}

// MARK: - SwiftUI Wrapper

struct TransparentVideoPlayer: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> TransparentVideoUIView {
        let view = TransparentVideoUIView()
        view.backgroundColor = .clear
        view.isOpaque = false
        return view
    }

    func updateUIView(_ uiView: TransparentVideoUIView, context: Context) {
        uiView.play(url: url)
    }

    static func dismantleUIView(_ uiView: TransparentVideoUIView, coordinator: ()) {
        uiView.stop()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()

        TransparentVideoPlayer(
            url: URL(string: "https://assets.masko.ai/bfcd12/leo-149f/shake-fluffy-mane-7934a174.mov")!
        )
        .frame(width: 200, height: 250)
    }
}

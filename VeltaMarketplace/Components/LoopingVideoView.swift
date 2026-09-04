import AVFoundation
import SwiftUI
import UIKit

final class PlayerCanvas: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

struct LoopingVideoView: UIViewRepresentable {
    let url: URL
    var isPlaying: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PlayerCanvas {
        let view = PlayerCanvas()
        view.backgroundColor = .black
        view.playerLayer.videoGravity = .resizeAspectFill
        context.coordinator.attach(url: url, to: view)
        return view
    }

    func updateUIView(_ uiView: PlayerCanvas, context: Context) {
        if context.coordinator.url != url {
            context.coordinator.attach(url: url, to: uiView)
        }
        context.coordinator.setPlaying(isPlaying)
    }

    static func dismantleUIView(_ uiView: PlayerCanvas, coordinator: Coordinator) {
        coordinator.tearDown()
    }

    @MainActor
    final class Coordinator {
        var url: URL?
        private var player: AVQueuePlayer?
        private var looper: AVPlayerLooper?

        func attach(url: URL, to view: PlayerCanvas) {
            tearDown()
            self.url = url
            let item = AVPlayerItem(url: url)
            let queue = AVQueuePlayer()
            queue.isMuted = false
            looper = AVPlayerLooper(player: queue, templateItem: item)
            player = queue
            view.playerLayer.player = queue
        }

        func setPlaying(_ playing: Bool) {
            if playing {
                player?.play()
            } else {
                player?.pause()
            }
        }

        func tearDown() {
            player?.pause()
            player?.removeAllItems()
            looper = nil
            player = nil
            url = nil
        }
    }
}

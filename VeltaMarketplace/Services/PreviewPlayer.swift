import AVFoundation
import Foundation

@MainActor
@Observable
final class PreviewPlayer {
    private(set) var playingBeatID: String?
    private(set) var isPlaying = false

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    func toggle(beat: Beat, candidates: [URL]) {
        if playingBeatID == beat.id, isPlaying {
            pause()
            return
        }
        Task { await play(beatID: beat.id, candidates: candidates) }
    }

    func play(beatID: String, candidates: [URL]) async {
        stop()

        for url in candidates {
            let item = AVPlayerItem(url: url)
            let player = AVPlayer(playerItem: item)

            if await waitUntilReady(item) {
                self.player = player
                playingBeatID = beatID
                isPlaying = true
                observeEnd(for: item)
                player.play()
                return
            }
        }

        playingBeatID = nil
        isPlaying = false
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        player?.pause()
        player = nil
        playingBeatID = nil
        isPlaying = false
    }

    private func waitUntilReady(_ item: AVPlayerItem) async -> Bool {
        for _ in 0 ..< 30 {
            switch item.status {
            case .readyToPlay:
                return true
            case .failed:
                return false
            default:
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
        return item.status == .readyToPlay
    }

    private func observeEnd(for item: AVPlayerItem) {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isPlaying = false
            }
        }
    }
}

import AVFoundation
import MediaPlayer
import Combine

// MARK: - Global player singleton

@MainActor
final class PlayerService: ObservableObject {
    static let shared = PlayerService()

    @Published var currentTrack: MonoTrack?
    @Published var queue: [MonoTrack] = []
    @Published var isPlaying = false
    @Published var progress: Float = 0       // 0...1
    @Published var currentTimeStr = "0:00"
    @Published var durationStr = "0:00"
    @Published var isLoading = false
    @Published var isShuffled = false
    @Published var repeatMode: RepeatMode = .off

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    private var bufferObserver: NSKeyValueObservation?
    private var queueIndex = 0
    private var cancellables = Set<AnyCancellable>()

    enum RepeatMode { case off, one, all }

    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Public

    func play(track: MonoTrack, queue: [MonoTrack] = []) {
        self.queue = queue.isEmpty ? [track] : queue
        queueIndex = queue.firstIndex(where: { $0.id == track.id }) ?? 0
        loadTrack(track)
    }

    func playPause() {
        guard let player else { return }
        if isPlaying { player.pause(); isPlaying = false }
        else { player.play(); isPlaying = true }
        updateNowPlaying()
    }

    func next() {
        let nextIdx: Int
        if isShuffled {
            nextIdx = Int.random(in: 0..<max(1, queue.count))
        } else {
            nextIdx = queueIndex + 1
            if nextIdx >= queue.count {
                if repeatMode == .all { loadTrack(queue[0]); queueIndex = 0; return }
                return
            }
        }
        queueIndex = nextIdx
        loadTrack(queue[queueIndex])
    }

    func previous() {
        let sec = player?.currentTime().seconds ?? 0
        if sec > 3 {
            player?.seek(to: .zero)
            return
        }
        let prev = max(0, queueIndex - 1)
        queueIndex = prev
        loadTrack(queue[prev])
    }

    func seek(to fraction: Float) {
        guard let duration = player?.currentItem?.duration, duration.isValid else { return }
        let seconds = Double(fraction) * duration.seconds
        player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600))
    }

    func toggleLike() async {
        guard var track = currentTrack else { return }
        do {
            if track.isLiked {
                try await APIService.shared.unlikeTrack(track.id)
            } else {
                try await APIService.shared.likeTrack(track.id)
            }
            track.isLiked.toggle()
            currentTrack = track
            if let idx = queue.firstIndex(where: { $0.id == track.id }) {
                queue[idx] = track
            }
        } catch { }
    }

    // MARK: - Private

    private func loadTrack(_ track: MonoTrack) {
        currentTrack = track
        isLoading = true
        isPlaying = false
        progress = 0

        removeObservers()

        Task {
            do {
                let urlString = try await APIService.shared.getStreamURL(trackId: track.id)
                guard let url = URL(string: urlString) else { throw MonoError.noStream }
                await startPlayback(url: url, track: track)
            } catch {
                await MainActor.run { isLoading = false }
            }
        }
    }

    private func startPlayback(url: URL, track: MonoTrack) async {
        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        // Observe stall / buffering to re-fetch URL
        bufferObserver = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] item, _ in
            guard item.isPlaybackBufferEmpty else { return }
            Task { @MainActor [weak self] in
                guard let self, self.currentTrack?.id == track.id else { return }
                self.isLoading = true
                // Re-fetch fresh URL
                do {
                    let freshURL = try await APIService.shared.getStreamURL(trackId: track.id)
                    if let url = URL(string: freshURL) {
                        await self.startPlayback(url: url, track: track)
                    }
                } catch { self.isLoading = false }
            }
        }

        // Observe playback end
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.repeatMode == .one { self.player?.seek(to: .zero); self.player?.play() }
                else { self.next() }
            }
        }

        addTimeObserver()

        player?.play()
        isPlaying = true
        isLoading = false
        updateNowPlaying()
    }

    private func addTimeObserver() {
        removeTimeObserver()
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self, let duration = self.player?.currentItem?.duration, duration.isValid, !duration.isIndefinite else { return }
            let current = time.seconds
            let total = duration.seconds
            self.progress = Float(current / max(1, total))
            self.currentTimeStr = Self.format(current)
            self.durationStr = Self.format(total)
        }
    }

    private func removeTimeObserver() {
        if let obs = timeObserver { player?.removeTimeObserver(obs); timeObserver = nil }
    }

    private func removeObservers() {
        removeTimeObserver()
        bufferObserver?.invalidate(); bufferObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }

    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            self?.player?.play(); self?.isPlaying = true
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause(); self?.isPlaying = false
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            self?.next(); return .success
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            self?.previous(); return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let e = event as? MPChangePlaybackPositionCommandEvent {
                self?.player?.seek(to: CMTime(seconds: e.positionTime, preferredTimescale: 600))
            }
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let track = currentTrack else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artistsString,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player?.currentTime().seconds ?? 0,
            MPMediaItemPropertyPlaybackDuration: player?.currentItem?.duration.seconds ?? Double(track.durationMs / 1000),
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let url = track.coverURL, let imageURL = URL(string: url),
           let data = try? Data(contentsOf: imageURL),
           let ui = UIImage(data: data) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: ui.size) { _ in ui }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private static func format(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

import Foundation
import AVFoundation

protocol AudioControllerDelegate: AnyObject {
    func audioController(_ controller: AudioController, didEmit state: [String: Any])
}

/// Manages audio playback and emits state maps to the EventChannel delegate.
final class AudioController: NSObject {

    weak var delegate: AudioControllerDelegate?

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var currentSurah: Int?
    private var currentAyah: Int?

    // MARK: - Commands

    func play(from map: [String: Any]) throws {
        guard let surah    = map["surahNumber"] as? Int,
              let reciter  = map["reciterId"]   as? String else {
            throw QuranBridgeError.invalidArgument("AudioRequest is malformed")
        }

        currentSurah = surah
        currentAyah  = map["fromAyah"] as? Int

        // TODO: integrate quran-ios library here — resolve audio URL from reciter + surah
        let urlString = audioURL(reciter: reciter, surah: surah)
        guard let url = URL(string: urlString) else {
            throw QuranBridgeError.audioError("Could not resolve audio URL for reciter '\(reciter)'")
        }

        emit(status: "loading")

        stop()

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: item
        )

        addProgressObserver()

        player?.play()
        emit(status: "playing")
    }

    func pause() {
        player?.pause()
        emit(status: "paused")
    }

    func stop() {
        removeProgressObserver()
        NotificationCenter.default.removeObserver(self)
        player?.pause()
        player = nil
        emit(status: "stopped")
    }

    // MARK: - Private

    private func addProgressObserver() {
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            let posMs = Int(time.seconds * 1000)
            let durMs = Int((self.player?.currentItem?.duration.seconds ?? 0) * 1000)
            self.emit(status: "playing", positionMs: posMs, durationMs: durMs)
        }
    }

    private func removeProgressObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    @objc private func playerDidFinish() {
        stop()
        emit(status: "stopped")
    }

    private func emit(
        status: String,
        positionMs: Int? = nil,
        durationMs: Int? = nil
    ) {
        var state: [String: Any] = ["status": status]
        if let s = currentSurah  { state["surahNumber"] = s }
        if let a = currentAyah   { state["ayahNumber"]  = a }
        if let p = positionMs    { state["positionMs"]  = p }
        if let d = durationMs    { state["durationMs"]  = d }
        delegate?.audioController(self, didEmit: state)
    }

    // TODO: integrate quran-ios library here — replace with real URL resolution
    private func audioURL(reciter: String, surah: Int) -> String {
        let paddedSurah = String(format: "%03d", surah)
        return "https://cdn.islamic.network/quran/audio-surah/128/\(reciter)/\(paddedSurah).mp3"
    }
}

// MARK: - Typed errors

enum QuranBridgeError: Error {
    case invalidArgument(String)
    case notFound(String)
    case audioError(String)

    var flutterError: FlutterError {
        switch self {
        case .invalidArgument(let msg):
            return FlutterError(code: "INVALID_ARGS",  message: msg, details: nil)
        case .notFound(let msg):
            return FlutterError(code: "NOT_FOUND",     message: msg, details: nil)
        case .audioError(let msg):
            return FlutterError(code: "AUDIO_ERROR",   message: msg, details: nil)
        }
    }
}

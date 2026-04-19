package dev.quran.bridge

import android.content.Context
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/// Manages audio playback and streams state via EventChannel.
class AudioController(private val context: Context) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var player: MediaPlayer? = null
    private val handler = Handler(Looper.getMainLooper())
    private var currentSurah: Int? = null
    private var currentAyah: Int? = null

    private val progressRunnable = object : Runnable {
        override fun run() {
            player?.takeIf { it.isPlaying }?.let {
                emit("playing", positionMs = it.currentPosition, durationMs = it.duration)
                handler.postDelayed(this, 500)
            }
        }
    }

    // ── StreamHandler ─────────────────────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // ── Commands ──────────────────────────────────────────────────────────────

    @Suppress("UNCHECKED_CAST")
    fun play(map: Map<String, Any>) {
        val surah   = map["surahNumber"] as? Int
            ?: throw QuranBridgeException.invalidArgs("surahNumber")
        val reciter = map["reciterId"] as? String
            ?: throw QuranBridgeException.invalidArgs("reciterId")

        currentSurah = surah
        currentAyah  = map["fromAyah"] as? Int

        emit("loading")
        stop()

        // TODO: integrate quran_android logic here — resolve audio URL from reciter + surah
        val url = resolveAudioUrl(reciter, surah)

        player = MediaPlayer().apply {
            setDataSource(url)
            setOnPreparedListener {
                it.start()
                emit("playing")
                handler.post(progressRunnable)
            }
            setOnCompletionListener {
                handler.removeCallbacks(progressRunnable)
                emit("stopped")
                release()
                player = null
            }
            setOnErrorListener { _, what, extra ->
                handler.removeCallbacks(progressRunnable)
                emitError("MediaPlayer error: what=$what extra=$extra")
                true
            }
            prepareAsync()
        }
    }

    fun pause() {
        player?.takeIf { it.isPlaying }?.pause()
        handler.removeCallbacks(progressRunnable)
        emit("paused")
    }

    fun stop() {
        handler.removeCallbacks(progressRunnable)
        player?.apply {
            if (isPlaying) stop()
            release()
        }
        player = null
        emit("stopped")
    }

    fun release() {
        stop()
        eventSink = null
    }

    // ── Private ───────────────────────────────────────────────────────────────

    private fun emit(
        status: String,
        positionMs: Int? = null,
        durationMs: Int? = null,
    ) {
        val state = mutableMapOf<String, Any>("status" to status)
        currentSurah?.let { state["surahNumber"] = it }
        currentAyah?.let  { state["ayahNumber"]  = it }
        positionMs?.let   { state["positionMs"]  = it }
        durationMs?.let   { state["durationMs"]  = it }
        eventSink?.success(state)
    }

    private fun emitError(message: String) {
        val state = mutableMapOf<String, Any>(
            "status"       to "error",
            "errorMessage" to message,
        )
        currentSurah?.let { state["surahNumber"] = it }
        eventSink?.success(state)
    }

    // TODO: integrate quran_android logic here — replace with real URL resolution
    private fun resolveAudioUrl(reciter: String, surah: Int): String {
        val paddedSurah = surah.toString().padStart(3, '0')
        return "https://cdn.islamic.network/quran/audio-surah/128/$reciter/$paddedSurah.mp3"
    }
}

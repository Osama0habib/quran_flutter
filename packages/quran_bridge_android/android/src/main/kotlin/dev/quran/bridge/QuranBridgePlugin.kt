package dev.quran.bridge

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private const val METHOD_CHANNEL = "dev.quran.bridge/methods"
private const val AUDIO_CHANNEL  = "dev.quran.bridge/audio"

class QuranBridgePlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context

    private lateinit var service: QuranNativeService
    private lateinit var audioController: AudioController

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    // ── FlutterPlugin ────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        service         = QuranNativeService(context)
        audioController = AudioController(context)

        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, AUDIO_CHANNEL)
        eventChannel.setStreamHandler(audioController)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        audioController.release()
        scope.cancel()
    }

    // ── MethodCallHandler ────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        scope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    dispatch(call)
                }
                result.success(response)
            } catch (e: QuranBridgeException) {
                result.error(e.code, e.message, e.details)
            } catch (e: Exception) {
                result.error("UNKNOWN", e.message ?: "Unknown error", null)
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    private suspend fun dispatch(call: MethodCall): Any? {
        val args = call.arguments as? Map<String, Any>

        return when (call.method) {
            "getSurahs"     -> service.getSurahs()

            "getPage"       -> {
                val page = args?.get("pageNumber") as? Int
                    ?: throw QuranBridgeException.invalidArgs("pageNumber")
                service.getPage(page)
            }

            "getVerses"     -> {
                val surah = args?.get("surah") as? Int
                    ?: throw QuranBridgeException.invalidArgs("surah")
                val from  = args["from"] as? Int
                val to    = args["to"]   as? Int
                service.getVerses(surah, from, to)
            }

            "addBookmark"   -> {
                val map = args ?: throw QuranBridgeException.invalidArgs("bookmark")
                service.bookmarkStore.add(map)
                null
            }

            "getBookmarks"  -> service.bookmarkStore.getAll()

            "removeBookmark" -> {
                val id = args?.get("id") as? String
                    ?: throw QuranBridgeException.invalidArgs("id")
                service.bookmarkStore.remove(id)
                null
            }

            "playAudio"     -> {
                val map = args ?: throw QuranBridgeException.invalidArgs("AudioRequest")
                withContext(Dispatchers.Main) { audioController.play(map) }
                null
            }

            "pauseAudio"    -> {
                withContext(Dispatchers.Main) { audioController.pause() }
                null
            }

            "stopAudio"     -> {
                withContext(Dispatchers.Main) { audioController.stop() }
                null
            }

            else -> throw UnsupportedOperationException("${call.method} not implemented")
        }
    }
}

import Flutter

private let kMethodChannel = "dev.quran.bridge/methods"
private let kAudioChannel  = "dev.quran.bridge/audio"

public class QuranBridgePlugin: NSObject, FlutterPlugin {

    private let service: QuranNativeService
    private let audioController: AudioController
    private var audioEventSink: FlutterEventSink?

    // MARK: - Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: kMethodChannel,
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: kAudioChannel,
            binaryMessenger: registrar.messenger()
        )

        let instance = QuranBridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - Init

    override init() {
        self.service = QuranNativeService()
        self.audioController = AudioController()
        super.init()
        self.audioController.delegate = self
    }

    // MARK: - MethodChannel dispatch

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]

        switch call.method {
        case "getSurahs":
            handleAsync(result: result) { try self.service.getSurahs() }

        case "getPage":
            guard let pageNumber = args?["pageNumber"] as? Int else {
                return result(invalidArgs("pageNumber"))
            }
            handleAsync(result: result) { try self.service.getPage(pageNumber) }

        case "getVerses":
            guard let surah = args?["surah"] as? Int else {
                return result(invalidArgs("surah"))
            }
            let from = args?["from"] as? Int
            let to   = args?["to"]   as? Int
            handleAsync(result: result) { try self.service.getVerses(surah: surah, from: from, to: to) }

        case "addBookmark":
            guard let map = args else { return result(invalidArgs("bookmark")) }
            handleAsync(result: result) { try self.service.bookmarkStore.add(from: map) }

        case "getBookmarks":
            handleAsync(result: result) { self.service.bookmarkStore.getAll() }

        case "removeBookmark":
            guard let id = args?["id"] as? String else {
                return result(invalidArgs("id"))
            }
            handleAsync(result: result) { self.service.bookmarkStore.remove(id: id) }

        case "playAudio":
            guard let map = args else { return result(invalidArgs("AudioRequest")) }
            handleAsync(result: result) { try self.audioController.play(from: map) }

        case "pauseAudio":
            handleAsync(result: result) { self.audioController.pause() }

        case "stopAudio":
            handleAsync(result: result) { self.audioController.stop() }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers

    /// Runs [body] on a background queue and marshals the result back to main.
    private func handleAsync(result: @escaping FlutterResult, body: @escaping () throws -> Any?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let value = try body()
                DispatchQueue.main.async { result(value) }
            } catch let error as QuranBridgeError {
                DispatchQueue.main.async { result(error.flutterError) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "UNKNOWN", message: error.localizedDescription, details: nil))
                }
            }
        }
    }

    private func invalidArgs(_ field: String) -> FlutterError {
        FlutterError(code: "INVALID_ARGS", message: "Missing or invalid argument: \(field)", details: nil)
    }
}

// MARK: - EventChannel stream handler

extension QuranBridgePlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        audioEventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        audioEventSink = nil
        return nil
    }
}

// MARK: - AudioControllerDelegate

extension QuranBridgePlugin: AudioControllerDelegate {
    func audioController(_ controller: AudioController, didEmit state: [String: Any]) {
        DispatchQueue.main.async {
            self.audioEventSink?(state)
        }
    }
}

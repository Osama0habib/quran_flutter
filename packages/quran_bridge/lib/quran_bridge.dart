library quran_bridge;

export 'package:quran_bridge_platform_interface/quran_bridge_platform_interface.dart'
    show
        Surah,
        Ayah,
        PageData,
        Bookmark,
        AudioRequest,
        AudioState,
        AudioStatus,
        QuranBridgeException;

import 'package:quran_bridge_platform_interface/quran_bridge_platform_interface.dart';

/// Primary entry point for all Quran Bridge operations.
///
/// All methods throw [QuranBridgeException] on native errors.
class QuranBridge {
  QuranBridge._();

  static QuranBridgePlatform get _platform => QuranBridgePlatform.instance;

  // ── Quran Data ────────────────────────────────────────────────────────────

  /// Returns metadata for all 114 surahs. Ayah text is not included.
  static Future<List<Surah>> getSurahs() => _platform.getSurahs();

  /// Returns all ayahs on [pageNumber] (1–604).
  static Future<PageData> getPage(int pageNumber) {
    assert(pageNumber >= 1 && pageNumber <= 604,
        'pageNumber must be between 1 and 604');
    return _platform.getPage(pageNumber);
  }

  /// Returns ayahs for [surah] (1-based), optionally bounded by [from]..[to].
  ///
  /// [from] and [to] are 1-based ayah numbers, inclusive.
  static Future<List<Ayah>> getVerses({
    required int surah,
    int? from,
    int? to,
  }) {
    assert(surah >= 1 && surah <= 114, 'surah must be between 1 and 114');
    assert(from == null || from >= 1, 'from must be >= 1');
    assert(to == null || from == null || to >= from, 'to must be >= from');
    return _platform.getVerses(surah: surah, from: from, to: to);
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  /// Persists [bookmark] to native storage.
  static Future<void> addBookmark(Bookmark bookmark) =>
      _platform.addBookmark(bookmark);

  /// Returns all persisted bookmarks, ordered by [Bookmark.createdAt] desc.
  static Future<List<Bookmark>> getBookmarks() => _platform.getBookmarks();

  /// Removes the bookmark with the given [id]. No-op if not found.
  static Future<void> removeBookmark(String id) =>
      _platform.removeBookmark(id);

  // ── Audio ─────────────────────────────────────────────────────────────────

  /// Begins playback as described by [request].
  ///
  /// Emits [AudioStatus.loading] then [AudioStatus.playing] via [audioStates].
  static Future<void> playAudio(AudioRequest request) =>
      _platform.playAudio(request);

  /// Pauses active playback. Emits [AudioStatus.paused] via [audioStates].
  static Future<void> pauseAudio() => _platform.pauseAudio();

  /// Stops and resets the audio engine. Emits [AudioStatus.stopped].
  static Future<void> stopAudio() => _platform.stopAudio();

  /// Broadcast stream of [AudioState] events from the native audio engine.
  ///
  /// The stream is lazy — the EventChannel is registered on first listen.
  /// Multiple listeners share the same underlying stream.
  static Stream<AudioState> audioStates() => _platform.audioStates();
}

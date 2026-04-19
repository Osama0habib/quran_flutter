import 'package:flutter/services.dart';

import 'platform_interface.dart';
import 'models/surah.dart';
import 'models/ayah.dart';
import 'models/page_data.dart';
import 'models/bookmark.dart';
import 'models/audio_request.dart';
import 'models/audio_state.dart';
import 'models/quran_bridge_exception.dart';

const String _kMethodChannel = 'dev.quran.bridge/methods';
const String _kAudioChannel = 'dev.quran.bridge/audio';

/// Default implementation wiring platform interface to Flutter channels.
class MethodChannelQuranBridge extends QuranBridgePlatform {
  final MethodChannel _channel = const MethodChannel(_kMethodChannel);
  final EventChannel _audioChannel = const EventChannel(_kAudioChannel);

  Stream<AudioState>? _audioStream;

  @override
  Future<List<Surah>> getSurahs() async {
    final result = await _invoke<List<dynamic>>('getSurahs');
    return result
        .map((e) => Surah.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<PageData> getPage(int pageNumber) async {
    final result = await _invoke<Map<dynamic, dynamic>>(
      'getPage',
      {'pageNumber': pageNumber},
    );
    return PageData.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<List<Ayah>> getVerses({
    required int surah,
    int? from,
    int? to,
  }) async {
    final result = await _invoke<List<dynamic>>('getVerses', {
      'surah': surah,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
    return result
        .map((e) => Ayah.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    await _invoke<void>('addBookmark', bookmark.toMap());
  }

  @override
  Future<List<Bookmark>> getBookmarks() async {
    final result = await _invoke<List<dynamic>>('getBookmarks');
    return result
        .map((e) => Bookmark.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> removeBookmark(String id) async {
    await _invoke<void>('removeBookmark', {'id': id});
  }

  @override
  Future<void> playAudio(AudioRequest request) async {
    await _invoke<void>('playAudio', request.toMap());
  }

  @override
  Future<void> pauseAudio() async {
    await _invoke<void>('pauseAudio');
  }

  @override
  Future<void> stopAudio() async {
    await _invoke<void>('stopAudio');
  }

  @override
  Stream<AudioState> audioStates() {
    _audioStream ??= _audioChannel
        .receiveBroadcastStream()
        .map((event) => AudioState.fromMap(
              Map<String, dynamic>.from(event as Map),
            ));
    return _audioStream!;
  }

  /// Wraps [MethodChannel.invokeMethod] and maps [PlatformException]
  /// to [QuranBridgeException].
  Future<T> _invoke<T>(String method, [dynamic arguments]) async {
    try {
      final result = await _channel.invokeMethod<T>(method, arguments);
      return result as T;
    } on PlatformException catch (e) {
      throw QuranBridgeException(
        code: e.code,
        message: e.message ?? 'Unknown platform error',
        details: e.details,
      );
    }
  }
}

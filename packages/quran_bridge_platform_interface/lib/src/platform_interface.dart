import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_quran_bridge.dart';
import 'models/surah.dart';
import 'models/ayah.dart';
import 'models/page_data.dart';
import 'models/bookmark.dart';
import 'models/audio_request.dart';
import 'models/audio_state.dart';

/// The contract every platform implementation must satisfy.
abstract class QuranBridgePlatform extends PlatformInterface {
  QuranBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static QuranBridgePlatform _instance = MethodChannelQuranBridge();

  static QuranBridgePlatform get instance => _instance;

  static set instance(QuranBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Surah>> getSurahs() => throw UnimplementedError('getSurahs()');

  Future<PageData> getPage(int pageNumber) =>
      throw UnimplementedError('getPage()');

  Future<List<Ayah>> getVerses({
    required int surah,
    int? from,
    int? to,
  }) =>
      throw UnimplementedError('getVerses()');

  Future<void> addBookmark(Bookmark bookmark) =>
      throw UnimplementedError('addBookmark()');

  Future<List<Bookmark>> getBookmarks() =>
      throw UnimplementedError('getBookmarks()');

  Future<void> removeBookmark(String id) =>
      throw UnimplementedError('removeBookmark()');

  Future<void> playAudio(AudioRequest request) =>
      throw UnimplementedError('playAudio()');

  Future<void> pauseAudio() => throw UnimplementedError('pauseAudio()');

  Future<void> stopAudio() => throw UnimplementedError('stopAudio()');

  Stream<AudioState> audioStates() => throw UnimplementedError('audioStates()');
}

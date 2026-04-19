import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

/// Streams the current [AudioState] from the native engine.
final audioStateProvider =
    AsyncNotifierProvider<AudioStateNotifier, AudioState>(
  AudioStateNotifier.new,
);

class AudioStateNotifier extends AsyncNotifier<AudioState> {
  StreamSubscription<AudioState>? _sub;

  @override
  Future<AudioState> build() async {
    ref.onDispose(() => _sub?.cancel());

    _sub = QuranBridge.audioStates().listen(
      (s) => state = AsyncData(s),
      onError: (Object e) => state = AsyncError(e, StackTrace.current),
    );

    return const AudioState(status: AudioStatus.idle);
  }
}

/// Exposes audio commands; screens call these instead of the plugin directly.
final audioControllerProvider = Provider<AudioController>((ref) {
  return AudioController(ref);
});

class AudioController {
  const AudioController(this._ref);

  final Ref _ref;

  Future<void> play(AudioRequest request) async {
    await QuranBridge.playAudio(request);
  }

  Future<void> pause() async {
    await QuranBridge.pauseAudio();
  }

  Future<void> stop() async {
    await QuranBridge.stopAudio();
  }

  /// Convenience — play the full surah with the default reciter.
  Future<void> playSurah(int surahNumber) => play(
        AudioRequest(surahNumber: surahNumber, reciterId: 'ar.alafasy'),
      );
}

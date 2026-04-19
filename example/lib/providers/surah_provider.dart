import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

/// Loads all 114 surahs once and caches them for the app lifetime.
final surahProvider = AsyncNotifierProvider<SurahNotifier, List<Surah>>(
  SurahNotifier.new,
);

class SurahNotifier extends AsyncNotifier<List<Surah>> {
  @override
  Future<List<Surah>> build() => QuranBridge.getSurahs();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(QuranBridge.getSurahs);
  }
}

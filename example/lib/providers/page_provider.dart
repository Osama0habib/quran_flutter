import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

/// Family provider — keyed by page number (1–604).
final pageProvider =
    AsyncNotifierProviderFamily<PageNotifier, PageData, int>(
  PageNotifier.new,
);

class PageNotifier extends FamilyAsyncNotifier<PageData, int> {
  @override
  Future<PageData> build(int arg) => QuranBridge.getPage(arg);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => QuranBridge.getPage(arg));
  }
}

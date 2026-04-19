import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

final bookmarkProvider =
    AsyncNotifierProvider<BookmarkNotifier, List<Bookmark>>(
  BookmarkNotifier.new,
);

class BookmarkNotifier extends AsyncNotifier<List<Bookmark>> {
  @override
  Future<List<Bookmark>> build() => QuranBridge.getBookmarks();

  Future<void> add(Bookmark bookmark) async {
    // Optimistic insert at front
    final prev = state.valueOrNull ?? [];
    state = AsyncData([bookmark, ...prev]);

    try {
      await QuranBridge.addBookmark(bookmark);
    } on QuranBridgeException {
      // Roll back on failure
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final prev = state.valueOrNull ?? [];
    state = AsyncData(prev.where((b) => b.id != id).toList());

    try {
      await QuranBridge.removeBookmark(id);
    } on QuranBridgeException {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(QuranBridge.getBookmarks);
  }
}

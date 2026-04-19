import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

/// Parameters for a verse range query.
class VersesParams {
  const VersesParams({required this.surah, this.from, this.to});

  final int surah;
  final int? from;
  final int? to;

  @override
  bool operator ==(Object other) =>
      other is VersesParams &&
      other.surah == surah &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(surah, from, to);
}

/// Family provider — keyed by [VersesParams].
final versesProvider =
    AsyncNotifierProviderFamily<VersesNotifier, List<Ayah>, VersesParams>(
  VersesNotifier.new,
);

class VersesNotifier extends FamilyAsyncNotifier<List<Ayah>, VersesParams> {
  @override
  Future<List<Ayah>> build(VersesParams arg) => QuranBridge.getVerses(
        surah: arg.surah,
        from: arg.from,
        to: arg.to,
      );

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => QuranBridge.getVerses(
        surah: arg.surah,
        from: arg.from,
        to: arg.to,
      ),
    );
  }
}

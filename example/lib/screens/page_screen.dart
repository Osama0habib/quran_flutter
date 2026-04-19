import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

import '../providers/page_provider.dart';
import '../providers/verses_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/ayah_tile.dart';

class PageScreen extends ConsumerWidget {
  const PageScreen({super.key, required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pageProvider(pageNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text('Page $pageNumber'),
        actions: [
          pageAsync.whenOrNull(
                data: (page) => _BookmarkButton(
                  surahNumber: page.surahNumbers.first,
                  pageNumber: pageNumber,
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: pageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(e.toString()),
        data: (page) => _PageContent(page: page),
      ),
    );
  }
}

class _PageContent extends ConsumerWidget {
  const _PageContent({required this.page});

  final PageData page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load verses for the first surah on this page
    final firstSurah = page.surahNumbers.first;
    final versesAsync = ref.watch(
      versesProvider(VersesParams(surah: firstSurah)),
    );
    final controller = ref.read(audioControllerProvider);

    return Column(
      children: [
        // Page metadata bar
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('Juz ${page.juzNumber}',
                  style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Text('Surahs: ${page.surahNumbers.join(', ')}',
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),

        // Audio play button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.play_circle_outline),
            label: Text('Play Surah $firstSurah'),
            onPressed: () => controller.playSurah(firstSurah),
          ),
        ),

        const Divider(height: 1),

        // Verses list
        Expanded(
          child: versesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(e.toString()),
            data: (ayahs) {
              if (ayahs.isEmpty) {
                return const _StubNotice();
              }
              return ListView.separated(
                itemCount: ayahs.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16),
                itemBuilder: (_, i) => AyahTile(ayah: ayahs[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({
    required this.surahNumber,
    required this.pageNumber,
  });

  final int surahNumber;
  final int pageNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkProvider).valueOrNull ?? [];
    final isBookmarked = bookmarks.any(
      (b) => b.surahNumber == surahNumber && b.ayahNumber == 1,
    );

    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
      ),
      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark this page',
      onPressed: () async {
        final notifier = ref.read(bookmarkProvider.notifier);
        try {
          if (isBookmarked) {
            final existing = bookmarks.firstWhere(
              (b) => b.surahNumber == surahNumber && b.ayahNumber == 1,
            );
            await notifier.remove(existing.id);
          } else {
            await notifier.add(Bookmark(
              id: '${surahNumber}_1_${DateTime.now().millisecondsSinceEpoch}',
              surahNumber: surahNumber,
              ayahNumber: 1,
              createdAt: DateTime.now(),
              label: 'Page $pageNumber',
            ));
          }
        } on QuranBridgeException catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message)),
            );
          }
        }
      },
    );
  }
}

class _StubNotice extends StatelessWidget {
  const _StubNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline,
              size: 40,
              color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            'Verse data not available yet.\nNative integration pending.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.error)),
      );
}

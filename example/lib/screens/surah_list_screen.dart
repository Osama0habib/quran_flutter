import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/surah_provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/surah_list_item.dart';

class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahAsync = ref.watch(surahProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surahs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(surahProvider.notifier).refresh(),
          ),
        ],
      ),
      body: surahAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.read(surahProvider.notifier).refresh(),
        ),
        data: (surahs) {
          if (surahs.isEmpty) {
            return const _EmptyState(message: 'No surahs available yet.');
          }
          return ListView.builder(
            itemCount: surahs.length,
            itemBuilder: (context, i) {
              final surah = surahs[i];
              return SurahListItem(
                surah: surah,
                onTap: () => context.pushNamed(
                  'page',
                  pathParameters: {'number': '${surah.number}'},
                ),
                onPlay: () => ref
                    .read(audioControllerProvider)
                    .playSurah(surah.number),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

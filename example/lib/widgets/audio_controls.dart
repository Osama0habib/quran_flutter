import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_bridge/quran_bridge.dart';

import '../providers/audio_provider.dart';

/// Persistent audio bar rendered above the bottom nav.
class AudioControls extends ConsumerWidget {
  const AudioControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioAsync = ref.watch(audioStateProvider);
    final controller = ref.read(audioControllerProvider);
    final theme = Theme.of(context);

    return audioAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        if (state.status == AudioStatus.idle ||
            state.status == AudioStatus.stopped) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Status indicator
              _StatusDot(state.status),
              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.surahNumber != null
                          ? 'Surah ${state.surahNumber}'
                          : 'Audio',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      '${_formatMs(state.positionMs)} / '
                      '${_formatMs(state.durationMs)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              if (state.status == AudioStatus.playing)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: controller.pause,
                )
              else if (state.status == AudioStatus.paused ||
                  state.status == AudioStatus.loading)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: state.surahNumber != null
                      ? () => controller.playSurah(state.surahNumber!)
                      : null,
                ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: controller.stop,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMs(int? ms) {
    if (ms == null || ms <= 0) return '--:--';
    final d = Duration(milliseconds: ms);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot(this.status);
  final AudioStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AudioStatus.playing => Colors.green,
      AudioStatus.loading => Colors.orange,
      AudioStatus.paused  => Colors.blue,
      AudioStatus.error   => Colors.red,
      _                   => Colors.grey,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

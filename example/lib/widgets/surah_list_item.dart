import 'package:flutter/material.dart';
import 'package:quran_bridge/quran_bridge.dart';

class SurahListItem extends StatelessWidget {
  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
    required this.onPlay,
  });

  final Surah surah;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '${surah.number}',
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(surah.nameTransliteration),
      subtitle: Text(
        '${surah.ayahCount} ayahs · ${surah.revelationType}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (surah.nameArabic.isNotEmpty)
            Text(
              surah.nameArabic,
              style: theme.textTheme.titleMedium,
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            tooltip: 'Play audio',
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

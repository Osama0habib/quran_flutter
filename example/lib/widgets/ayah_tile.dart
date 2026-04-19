import 'package:flutter/material.dart';
import 'package:quran_bridge/quran_bridge.dart';

class AyahTile extends StatelessWidget {
  const AyahTile({super.key, required this.ayah});

  final Ayah ayah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse number badge + Arabic text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AyahBadge(number: ayah.ayahNumber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ayah.textArabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.titleMedium?.copyWith(
                    height: 1.8,
                    fontFamily: 'serif',
                  ),
                ),
              ),
            ],
          ),
          // Translation (if available)
          if (ayah.textTranslation != null) ...[
            const SizedBox(height: 8),
            Text(
              ayah.textTranslation!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahBadge extends StatelessWidget {
  const _AyahBadge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Text(
        '$number',
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}

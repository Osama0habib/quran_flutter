import 'package:flutter/material.dart';
import 'package:quran_bridge/quran_bridge.dart';

class BookmarkTile extends StatelessWidget {
  const BookmarkTile({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        child: Icon(
          Icons.bookmark,
          color: theme.colorScheme.onTertiaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        bookmark.label ?? '${bookmark.surahNumber}:${bookmark.ayahNumber}',
      ),
      subtitle: Text(
        'Surah ${bookmark.surahNumber} · Ayah ${bookmark.ayahNumber}\n'
        '${_formatDate(bookmark.createdAt)}',
        style: theme.textTheme.bodySmall,
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove',
        onPressed: onDelete,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}

/// Represents a user-saved position in the Quran.
class Bookmark {
  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.label,
  });

  final String id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;

  /// Optional user-provided label.
  final String? label;

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      if (label != null) 'label': label,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Bookmark && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Bookmark($id, $surahNumber:$ayahNumber)';
}

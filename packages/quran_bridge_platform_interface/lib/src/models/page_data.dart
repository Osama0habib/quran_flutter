import 'ayah.dart';

/// Represents a single mushaf page with its contained ayahs.
class PageData {
  const PageData({
    required this.pageNumber,
    required this.ayahs,
    required this.surahNumbers,
    required this.juzNumber,
  });

  final int pageNumber;
  final List<Ayah> ayahs;

  /// Surahs that appear on this page (may be more than one).
  final List<int> surahNumbers;
  final int juzNumber;

  factory PageData.fromMap(Map<String, dynamic> map) {
    return PageData(
      pageNumber: map['pageNumber'] as int,
      ayahs: (map['ayahs'] as List<dynamic>)
          .map((e) => Ayah.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      surahNumbers: List<int>.from(map['surahNumbers'] as List<dynamic>),
      juzNumber: map['juzNumber'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'ayahs': ayahs.map((a) => a.toMap()).toList(),
      'surahNumbers': surahNumbers,
      'juzNumber': juzNumber,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageData && other.pageNumber == pageNumber;

  @override
  int get hashCode => pageNumber.hashCode;

  @override
  String toString() => 'PageData(page: $pageNumber, ayahs: ${ayahs.length})';
}

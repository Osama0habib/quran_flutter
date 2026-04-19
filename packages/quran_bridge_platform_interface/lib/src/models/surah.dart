import 'ayah.dart';

/// Represents a single Surah (chapter) of the Quran.
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.ayahCount,
    required this.revelationType,
    this.ayahs = const [],
  });

  final int number;
  final String name;
  final String nameArabic;
  final String nameTransliteration;
  final int ayahCount;

  /// Either 'meccan' or 'medinan'.
  final String revelationType;

  /// Populated only when ayahs are fetched alongside surah data.
  final List<Ayah> ayahs;

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['number'] as int,
      name: map['name'] as String,
      nameArabic: map['nameArabic'] as String,
      nameTransliteration: map['nameTransliteration'] as String,
      ayahCount: map['ayahCount'] as int,
      revelationType: map['revelationType'] as String,
      ayahs: (map['ayahs'] as List<dynamic>?)
              ?.map((e) => Ayah.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'nameArabic': nameArabic,
      'nameTransliteration': nameTransliteration,
      'ayahCount': ayahCount,
      'revelationType': revelationType,
      'ayahs': ayahs.map((a) => a.toMap()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Surah && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Surah($number, $nameTransliteration)';
}

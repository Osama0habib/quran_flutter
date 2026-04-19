/// Represents a single Ayah (verse) of the Quran.
class Ayah {
  const Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textArabic,
    required this.pageNumber,
    required this.juzNumber,
    this.textTranslation,
    this.audioUrl,
  });

  final int surahNumber;
  final int ayahNumber;
  final String textArabic;
  final int pageNumber;
  final int juzNumber;
  final String? textTranslation;
  final String? audioUrl;

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      textArabic: map['textArabic'] as String,
      pageNumber: map['pageNumber'] as int,
      juzNumber: map['juzNumber'] as int,
      textTranslation: map['textTranslation'] as String?,
      audioUrl: map['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'textArabic': textArabic,
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      if (textTranslation != null) 'textTranslation': textTranslation,
      if (audioUrl != null) 'audioUrl': audioUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayah &&
          other.surahNumber == surahNumber &&
          other.ayahNumber == ayahNumber;

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);

  @override
  String toString() => 'Ayah($surahNumber:$ayahNumber)';
}

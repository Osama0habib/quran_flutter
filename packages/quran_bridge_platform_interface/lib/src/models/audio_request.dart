/// Describes what audio to play and how.
class AudioRequest {
  const AudioRequest({
    required this.surahNumber,
    required this.reciterId,
    this.fromAyah,
    this.toAyah,
    this.repeatCount = 1,
  }) : assert(repeatCount >= 1, 'repeatCount must be >= 1');

  final int surahNumber;

  /// Identifier matching the reciter in the native audio library.
  final String reciterId;

  /// Starting ayah (1-based). Defaults to first ayah if null.
  final int? fromAyah;

  /// Ending ayah (1-based, inclusive). Defaults to last ayah if null.
  final int? toAyah;

  /// Number of times to repeat the range.
  final int repeatCount;

  factory AudioRequest.fromMap(Map<String, dynamic> map) {
    return AudioRequest(
      surahNumber: map['surahNumber'] as int,
      reciterId: map['reciterId'] as String,
      fromAyah: map['fromAyah'] as int?,
      toAyah: map['toAyah'] as int?,
      repeatCount: (map['repeatCount'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'surahNumber': surahNumber,
      'reciterId': reciterId,
      if (fromAyah != null) 'fromAyah': fromAyah,
      if (toAyah != null) 'toAyah': toAyah,
      'repeatCount': repeatCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioRequest &&
          other.surahNumber == surahNumber &&
          other.reciterId == reciterId &&
          other.fromAyah == fromAyah &&
          other.toAyah == toAyah &&
          other.repeatCount == repeatCount;

  @override
  int get hashCode =>
      Object.hash(surahNumber, reciterId, fromAyah, toAyah, repeatCount);
}

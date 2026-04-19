/// The playback status emitted by the audio EventChannel.
enum AudioStatus { idle, loading, playing, paused, stopped, error }

/// Snapshot of the audio engine at a point in time.
class AudioState {
  const AudioState({
    required this.status,
    this.surahNumber,
    this.ayahNumber,
    this.positionMs,
    this.durationMs,
    this.errorMessage,
  });

  final AudioStatus status;
  final int? surahNumber;
  final int? ayahNumber;
  final int? positionMs;
  final int? durationMs;
  final String? errorMessage;

  factory AudioState.fromMap(Map<String, dynamic> map) {
    return AudioState(
      status: AudioStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => AudioStatus.idle,
      ),
      surahNumber: map['surahNumber'] as int?,
      ayahNumber: map['ayahNumber'] as int?,
      positionMs: map['positionMs'] as int?,
      durationMs: map['durationMs'] as int?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      if (surahNumber != null) 'surahNumber': surahNumber,
      if (ayahNumber != null) 'ayahNumber': ayahNumber,
      if (positionMs != null) 'positionMs': positionMs,
      if (durationMs != null) 'durationMs': durationMs,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioState &&
          other.status == status &&
          other.surahNumber == surahNumber &&
          other.ayahNumber == ayahNumber &&
          other.positionMs == positionMs;

  @override
  int get hashCode =>
      Object.hash(status, surahNumber, ayahNumber, positionMs);

  @override
  String toString() => 'AudioState($status, $surahNumber:$ayahNumber)';
}

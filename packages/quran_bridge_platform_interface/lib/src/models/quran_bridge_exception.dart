/// Typed error surfaced from native platform calls.
class QuranBridgeException implements Exception {
  const QuranBridgeException({
    required this.code,
    required this.message,
    this.details,
  });

  /// Machine-readable error code (e.g. 'NOT_FOUND', 'AUDIO_ERROR').
  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'QuranBridgeException[$code]: $message';
}

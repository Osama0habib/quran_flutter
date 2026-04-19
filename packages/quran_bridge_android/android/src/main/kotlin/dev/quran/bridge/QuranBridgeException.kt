package dev.quran.bridge

/// Typed exception surfaced through the MethodChannel result.
class QuranBridgeException(
    val code: String,
    override val message: String,
    val details: Any? = null,
) : Exception(message) {

    companion object {
        fun invalidArgs(field: String) =
            QuranBridgeException("INVALID_ARGS", "Missing or invalid argument: $field")

        fun notFound(resource: String) =
            QuranBridgeException("NOT_FOUND", "Resource not found: $resource")

        fun audioError(msg: String) =
            QuranBridgeException("AUDIO_ERROR", msg)
    }
}

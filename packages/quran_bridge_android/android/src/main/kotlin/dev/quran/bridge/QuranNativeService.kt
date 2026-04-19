package dev.quran.bridge

import android.content.Context

/// Bridges method channel calls to native Quran data logic.
class QuranNativeService(private val context: Context) {

    val bookmarkStore = BookmarkStore(context)

    // ── Surahs ───────────────────────────────────────────────────────────────

    fun getSurahs(): List<Map<String, Any>> {
        // TODO: integrate quran_android logic here — replace stub with real data source
        return (1..114).map { number ->
            mapOf(
                "number"              to number,
                "name"                to "Surah $number",
                "nameArabic"          to "",
                "nameTransliteration" to "Surah $number",
                "ayahCount"           to 7,
                "revelationType"      to "meccan",
                "ayahs"               to emptyList<Map<String, Any>>(),
            )
        }
    }

    // ── Pages ────────────────────────────────────────────────────────────────

    fun getPage(pageNumber: Int): Map<String, Any> {
        if (pageNumber < 1 || pageNumber > 604) {
            throw QuranBridgeException.invalidArgs("pageNumber out of range: $pageNumber")
        }
        // TODO: integrate quran_android logic here — fetch real page data
        return mapOf(
            "pageNumber"    to pageNumber,
            "ayahs"         to emptyList<Map<String, Any>>(),
            "surahNumbers"  to listOf(1),
            "juzNumber"     to 1,
        )
    }

    // ── Verses ───────────────────────────────────────────────────────────────

    fun getVerses(surah: Int, from: Int?, to: Int?): List<Map<String, Any>> {
        if (surah < 1 || surah > 114) {
            throw QuranBridgeException.invalidArgs("surah out of range: $surah")
        }
        // TODO: integrate quran_android logic here — fetch real ayah range
        return emptyList()
    }
}

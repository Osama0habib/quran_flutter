package dev.quran.bridge

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONObject

/// Persists bookmarks in SharedPreferences as JSON objects keyed by id.
class BookmarkStore(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("quran_bridge.bookmarks", Context.MODE_PRIVATE)

    // ── Read ─────────────────────────────────────────────────────────────────

    fun getAll(): List<Map<String, Any>> {
        return prefs.all.values
            .filterIsInstance<String>()
            .mapNotNull { json ->
                runCatching { jsonToMap(JSONObject(json)) }.getOrNull()
            }
            .sortedByDescending { it["createdAt"] as? Int ?: 0 }
    }

    // ── Write ────────────────────────────────────────────────────────────────

    fun add(map: Map<String, Any>) {
        val id = map["id"] as? String
        if (id.isNullOrEmpty()) {
            throw QuranBridgeException.invalidArgs("Bookmark.id is missing or empty")
        }
        val json = mapToJson(map).toString()
        prefs.edit().putString(id, json).apply()
    }

    // ── Delete ───────────────────────────────────────────────────────────────

    fun remove(id: String): Boolean {
        if (!prefs.contains(id)) return false
        prefs.edit().remove(id).apply()
        return true
    }

    // ── Serialization ────────────────────────────────────────────────────────

    private fun mapToJson(map: Map<String, Any>): JSONObject {
        val obj = JSONObject()
        map.forEach { (k, v) -> obj.put(k, v) }
        return obj
    }

    private fun jsonToMap(obj: JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        obj.keys().forEach { key ->
            map[key] = obj.get(key)
        }
        return map
    }
}

import Foundation

/// Persists bookmarks to UserDefaults.
///
/// Uses a keyed dictionary so individual entries can be removed without
/// deserializing the full list.
final class BookmarkStore {

    private let defaults = UserDefaults.standard
    private let storageKey = "quran_bridge.bookmarks"

    // MARK: - Read

    func getAll() -> [[String: Any]] {
        let raw = defaults.dictionary(forKey: storageKey) ?? [:]
        return raw.values
            .compactMap { $0 as? [String: Any] }
            .sorted {
                let a = $0["createdAt"] as? Int ?? 0
                let b = $1["createdAt"] as? Int ?? 0
                return a > b
            }
    }

    // MARK: - Write

    func add(from map: [String: Any]) throws {
        guard let id = map["id"] as? String, !id.isEmpty else {
            throw QuranBridgeError.invalidArgument("Bookmark.id is missing or empty")
        }
        var store = defaults.dictionary(forKey: storageKey) ?? [:]
        store[id] = map
        defaults.set(store, forKey: storageKey)
    }

    // MARK: - Delete

    @discardableResult
    func remove(id: String) -> Bool {
        var store = defaults.dictionary(forKey: storageKey) ?? [:]
        guard store[id] != nil else { return false }
        store.removeValue(forKey: id)
        defaults.set(store, forKey: storageKey)
        return true
    }
}

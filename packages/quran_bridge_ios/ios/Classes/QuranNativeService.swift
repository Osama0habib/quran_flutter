import Foundation

/// Bridges method channel calls to native Quran data logic.
final class QuranNativeService {

    let bookmarkStore = BookmarkStore()

    // MARK: - Surahs

    func getSurahs() throws -> [[String: Any]] {
        // TODO: integrate quran-ios library here — replace stub with real data source
        return (1...114).map { number in
            [
                "number": number,
                "name": "Surah \(number)",
                "nameArabic": "",
                "nameTransliteration": "Surah \(number)",
                "ayahCount": 7,
                "revelationType": "meccan",
                "ayahs": [] as [[String: Any]],
            ]
        }
    }

    // MARK: - Pages

    func getPage(_ pageNumber: Int) throws -> [String: Any] {
        guard pageNumber >= 1 && pageNumber <= 604 else {
            throw QuranBridgeError.invalidArgument("pageNumber out of range: \(pageNumber)")
        }
        // TODO: integrate quran-ios library here — fetch real page data
        return [
            "pageNumber": pageNumber,
            "ayahs": [] as [[String: Any]],
            "surahNumbers": [1] as [Int],
            "juzNumber": 1,
        ]
    }

    // MARK: - Verses

    func getVerses(surah: Int, from: Int?, to: Int?) throws -> [[String: Any]] {
        guard surah >= 1 && surah <= 114 else {
            throw QuranBridgeError.invalidArgument("surah out of range: \(surah)")
        }
        // TODO: integrate quran-ios library here — fetch real ayah range
        return []
    }
}

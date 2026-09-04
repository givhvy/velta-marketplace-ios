import Foundation

enum MediaCDN {
    static let primaryBase = URL(string: "https://wavs.huy.global")!
    static let fallbackBase = URL(string: "https://pub-5ef8d67300c44c55bf62d208c2663be4.r2.dev")!

    static func resolve(_ raw: String?, primary: URL, fallback: URL) -> [URL] {
        guard let raw, !raw.isEmpty else { return [] }

        if let absolute = URL(string: raw), absolute.scheme != nil {
            return [absolute]
        }

        let clean = raw.hasPrefix("/") ? String(raw.dropFirst()) : raw
        let primaryURL = primary.appendingPathComponent(clean)
        if primary == fallback {
            return [primaryURL]
        }
        return [primaryURL, fallback.appendingPathComponent(clean)]
    }

    static func defaultPreviewKey(for beat: Beat) -> String {
        "marketplace/previews/\(beat.slug).mp3"
    }
}

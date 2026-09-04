import Foundation

@MainActor
@Observable
final class CatalogStore {
    private(set) var beats: [Beat] = []
    private(set) var clips: [UsageClip] = []
    private(set) var webBase = URL(string: "http://127.0.0.1:3000")!
    private(set) var mediaBase = MediaCDN.primaryBase
    private(set) var mediaFallbackBase = MediaCDN.fallbackBase
    private(set) var isLive = false
    private(set) var loadError: String?

    var trending: [Beat] {
        Array(beats.sorted { $0.plays > $1.plays }.prefix(12))
    }

    var notable: [Beat] {
        Array(beats.sorted { $0.createdAt > $1.createdAt }.prefix(8))
    }

    func beat(id: String) -> Beat? {
        beats.first { $0.id == id }
    }

    func search(_ query: String) -> [Beat] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return trending }
        return beats.filter { beat in
            beat.title.lowercased().contains(needle)
                || beat.sellerName.lowercased().contains(needle)
                || beat.genres.contains { $0.lowercased().contains(needle) }
                || beat.tags.contains { $0.lowercased().contains(needle) }
        }
    }

    func load() async {
        loadError = nil
        clips = Self.bundledClips()
        if let live = await fetchLive() {
            beats = live.beats
            if let base = live.webBase, let url = URL(string: base) {
                webBase = url
            }
            if let base = live.mediaBase, let url = URL(string: base) {
                mediaBase = url
            }
            if let base = live.mediaFallbackBase, let url = URL(string: base) {
                mediaFallbackBase = url
            }
            isLive = true
            return
        }

        beats = Self.bundledBeats()
        isLive = false
        if beats.isEmpty {
            loadError = "Catalog unavailable."
        }
    }

    func submitPurchase(beatId: String, tier: String, authorization: String? = nil) async -> MobilePurchase? {
        let endpoints = [
            webBase.appending(path: "api/mobile/checkout"),
            URL(string: "http://127.0.0.1:3000/api/mobile/checkout"),
            URL(string: "http://localhost:3000/api/mobile/checkout"),
        ].compactMap { $0 }

        let body: [String: String] = ["beatId": beatId, "tier": tier]
        guard let payload = try? JSONEncoder().encode(body) else { return nil }

        for url in endpoints {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let authorization {
                request.setValue(authorization, forHTTPHeaderField: "Authorization")
            }
            request.httpBody = payload
            request.timeoutInterval = 4
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                    continue
                }
                return try JSONDecoder().decode(MobilePurchaseResponse.self, from: data).purchase
            } catch {
                continue
            }
        }
        return nil
    }

    private func fetchLive() async -> CatalogPayload? {
        let candidates = [
            URL(string: "http://127.0.0.1:3000/api/catalog"),
            URL(string: "http://localhost:3000/api/catalog"),
        ].compactMap { $0 }

        for url in candidates {
            var request = URLRequest(url: url)
            request.timeoutInterval = 2.5
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    continue
                }
                return try JSONDecoder().decode(CatalogPayload.self, from: data)
            } catch {
                continue
            }
        }
        return nil
    }

    func clips(for beatId: String) -> [UsageClip] {
        clips.filter { $0.beatId == beatId }
    }

    private static func bundledBeats() -> [Beat] {
        guard let url = Bundle.main.url(forResource: "beats", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let beats = try? JSONDecoder().decode([Beat].self, from: data)
        else {
            return []
        }
        return beats
    }

    private static func bundledClips() -> [UsageClip] {
        guard let url = Bundle.main.url(forResource: "clips", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let clips = try? JSONDecoder().decode([UsageClip].self, from: data)
        else {
            return []
        }
        return clips
    }
}

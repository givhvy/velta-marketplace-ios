import Foundation

struct CatalogPayload: Decodable, Sendable {
    var app: String?
    var webBase: String?
    var beats: [Beat]
}

struct Beat: Identifiable, Hashable, Decodable, Sendable {
    var id: String
    var slug: String
    var title: String
    var bpm: Int
    var key: String
    var genres: [String]
    var tags: [String]
    var coverGradient: String
    var coverImageUrl: String?
    var previewUrl: String?
    var sellerId: String
    var sellerName: String
    var sellerVerified: Bool
    var plays: Int
    var likes: Int
    var featured: Bool
    var licenses: [BeatLicense]
    var createdAt: String

    var lowestPrice: Double {
        licenses.map(\.price).min() ?? 0
    }

    var genreLine: String {
        genres.prefix(2).joined(separator: " · ")
    }

    func coverURL(webBase: URL) -> URL? {
        guard let coverImageUrl, coverImageUrl.hasPrefix("/") else { return nil }
        return webBase.appendingPathComponent(String(coverImageUrl.dropFirst()))
    }

    func license(tier: String) -> BeatLicense? {
        licenses.first { $0.tier == tier }
    }
}

struct BeatLicense: Identifiable, Hashable, Decodable, Sendable {
    var tier: String
    var label: String
    var price: Double
    var whopPlanId: String?
    var description: String

    var id: String { tier }
}

struct CartItem: Identifiable, Hashable, Codable, Sendable {
    var beatId: String
    var tier: String

    var id: String { "\(beatId)-\(tier)" }
}

struct OwnedLicense: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var beatId: String
    var tier: String
    var label: String
    var amount: Double
    var purchasedAt: String
}

struct CheckoutTarget: Identifiable, Hashable {
    var beatId: String
    var tier: String

    var id: String { "\(beatId)-\(tier)" }
}

enum HomePane: Hashable {
    case forYou, beats
}

enum AppTab: Hashable, CaseIterable {
    case explore, search, cart, library, menu
}

enum AppRoute: Hashable {
    case beat(String)
    case studio
    case login
    case orders
    case payments
    case settings
    case help
    case legal(LegalDocument)
}

struct MobilePurchaseResponse: Decodable, Sendable {
    var ok: Bool?
    var purchase: MobilePurchase?
}

struct MobilePurchase: Decodable, Sendable {
    var id: String
    var beatId: String
    var licenseTier: String
    var amount: Double
    var createdAt: String
}

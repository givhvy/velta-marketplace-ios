import Foundation

struct CatalogPayload: Decodable, Sendable {
    var app: String?
    var webBase: String?
    var mediaBase: String?
    var mediaFallbackBase: String?
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
    var demoPreviewUrl: String?
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
        guard let coverImageUrl else { return nil }
        if coverImageUrl.hasPrefix("http"), let url = URL(string: coverImageUrl) {
            return url
        }
        if coverImageUrl.hasPrefix("/") {
            return webBase.appendingPathComponent(String(coverImageUrl.dropFirst()))
        }
        return nil
    }

    func previewCandidates(primary: URL, fallback: URL) -> [URL] {
        var urls = MediaCDN.resolve(previewUrl ?? MediaCDN.defaultPreviewKey(for: self), primary: primary, fallback: fallback)
        if let demoPreviewUrl, let demo = URL(string: demoPreviewUrl) {
            urls.append(demo)
        }
        return urls
    }

    func license(tier: String) -> BeatLicense? {
        licenses.first { $0.tier == tier }
    }

    func downloadFiles(for tier: String) -> [LicenseDownloadFile] {
        switch tier {
        case "exclusive":
            return [
                LicenseDownloadFile(label: "Exclusive WAV", fileName: "\(slug)-exclusive.wav", path: "marketplace/downloads/\(slug)-exclusive.wav"),
                LicenseDownloadFile(label: "Stems ZIP", fileName: "\(slug)-stems.zip", path: "marketplace/downloads/\(slug)-stems.zip"),
                LicenseDownloadFile(label: "License PDF", fileName: "\(slug)-license.pdf", path: "marketplace/licenses/\(slug).pdf"),
            ]
        case "wav":
            return [
                LicenseDownloadFile(label: "Untagged WAV", fileName: "\(slug).wav", path: "marketplace/downloads/\(slug).wav"),
                LicenseDownloadFile(label: "Tagged MP3", fileName: "\(slug)-tagged.mp3", path: "marketplace/downloads/\(slug)-tagged.mp3"),
            ]
        default:
            return [
                LicenseDownloadFile(label: "Tagged MP3", fileName: "\(slug)-tagged.mp3", path: "marketplace/downloads/\(slug)-tagged.mp3"),
            ]
        }
    }

    func downloadCandidates(for tier: String, primary: URL, fallback: URL) -> [(file: LicenseDownloadFile, urls: [URL])] {
        let previews = previewCandidates(primary: primary, fallback: fallback)
        return downloadFiles(for: tier).map { file in
            var urls = MediaCDN.resolve(file.path, primary: primary, fallback: fallback)
            if urls.isEmpty || file.path.hasSuffix(".pdf") || file.path.hasSuffix(".zip") {
                urls.append(contentsOf: previews)
            }
            return (file, urls)
        }
    }
}

struct LicenseDownloadFile: Identifiable, Hashable, Sendable {
    var label: String
    var fileName: String
    var path: String

    var id: String { path }
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

    var invoiceNumber: String {
        let core = id.replacingOccurrences(of: "local_", with: "").uppercased()
        return "VL\(String(core.prefix(12)))"
    }
}

struct CheckoutTarget: Identifiable, Hashable {
    var beatId: String
    var tier: String

    var id: String { "\(beatId)-\(tier)" }
}

enum AppTab: Hashable, CaseIterable {
    case video, beats, cart, library, menu
}

enum AppRoute: Hashable {
    case beat(String)
    case license(String)
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

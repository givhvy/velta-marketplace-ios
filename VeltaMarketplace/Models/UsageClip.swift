import Foundation

struct UsageClip: Identifiable, Hashable, Codable, Sendable {
    var id: String
    var beatId: String
    var creatorName: String
    var caption: String
    var videoURL: String
    var likes: Int
    var location: String

    var url: URL? { URL(string: videoURL) }
}

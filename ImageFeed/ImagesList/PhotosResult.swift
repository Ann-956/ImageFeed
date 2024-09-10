import Foundation

struct PhotoResponse: Codable {
    let photo: PhotosResult
}

struct PhotosResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    var likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}


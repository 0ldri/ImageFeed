import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let creatAt: String?
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case creatAt = "created_at"
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
    
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

extension Photo {
    init(from result: PhotoResult) {
        let dateFormatter = ISO8601DateFormatter()
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.creatAt.flatMap { dateFormatter.date(from: $0) }
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}


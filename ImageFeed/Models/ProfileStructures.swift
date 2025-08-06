import Kingfisher
import UIKit
import Foundation

struct ProfileResult: Decodable {
    let userLogin: String
    let firstName: String
    let lastName: String
    let bio: String?
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case userLogin = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct AvatarImageParameters {
    let url: URL
    let placeholder: UIImage?
    let processor: ImageProcessor?
    let options: KingfisherOptionsInfo
}

struct LogoutAlertModel {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
}

extension Profile {
    init(result profile: ProfileResult) {
        self.init(
            username: profile.userLogin,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userLogin)",
            bio: profile.bio
        )
    }
}

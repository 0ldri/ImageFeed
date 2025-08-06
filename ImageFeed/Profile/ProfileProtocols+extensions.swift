import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func confirmLogout()
}

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(with parameters: AvatarImageParameters)
    func showLogoutConfirmation(alertModel: LogoutAlertModel)
    func switchToSplashScreen()
}

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    func reset()
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    func reset()
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

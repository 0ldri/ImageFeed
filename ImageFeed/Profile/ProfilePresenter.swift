import Foundation
import Kingfisher
import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    
    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        setupObservers()
        loadProfileData()
    }
    
    private func getAvatarParameters(for url: URL) -> AvatarImageParameters {
            let placeholder = UIImage(systemName: "person.crop.circle.fill")?
                .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
            
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            
            return AvatarImageParameters(
                url: url,
                placeholder: placeholder,
                processor: processor,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .forceRefresh
                ]
            )
        }
    private func getLogoutAlertModel() -> LogoutAlertModel {
            LogoutAlertModel(
                title: "Пока, пока!",
                message: "Уверены, что хотите выйти?",
                confirmText: "Да",
                cancelText: "Нет"
            )
        }
    
    func updateAvatar() {
            guard
                let profileImageURL = profileImageService.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            
            let parameters = getAvatarParameters(for: url)
            view?.updateAvatar(with: parameters)
        }
        
        func didTapLogoutButton() {
            let alertModel = getLogoutAlertModel()
            view?.showLogoutConfirmation(alertModel: alertModel)
        }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func loadProfileData() {
        if let profile = profileService.profile {
                view?.updateProfileDetails(
                    name: profile.name ?? "",
                    loginName: profile.loginName ?? "",
                    bio: profile.bio ?? ""
                )
        }
        updateAvatar()
    }
    
    func confirmLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }
}

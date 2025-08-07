@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutConfirmationCalled = false
    var switchToSplashScreenCalled = false

    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
    }

    func updateAvatar(with parameters: AvatarImageParameters) {
        updateAvatarCalled = true
    }

    func showLogoutConfirmation(alertModel: LogoutAlertModel) {
        showLogoutConfirmationCalled = true
    }

    func switchToSplashScreen() {
        switchToSplashScreenCalled = true
    }
}


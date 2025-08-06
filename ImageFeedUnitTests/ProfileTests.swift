@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()

        viewController.loadViewIfNeeded()
        presenter.view = viewController
        viewController.setValue(presenter, forKey: "presenter")
        
        viewController.viewDidLoad()
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdateProfileDetails() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared,
            logoutService: ProfileLogoutService.shared
        )
        presenter.view = view

        presenter.viewDidLoad()
        
        XCTAssertTrue(view.updateProfileDetailsCalled)
    }

    func testPresenterCallsUpdateAvatar() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared,
            logoutService: ProfileLogoutService.shared
        )
        presenter.view = view

        presenter.viewDidLoad()
        
        XCTAssertTrue(view.updateAvatarCalled)
    }

    func testPresenterDidTapLogoutCallsShowAlert() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        presenter.didTapLogoutButton()
        
        XCTAssertTrue(view.showLogoutConfirmationCalled)
    }

    func testPresenterConfirmLogoutSwitchesToSplashScreen() {
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        presenter.confirmLogout()
        
        XCTAssertTrue(view.switchToSplashScreenCalled)
    }

    func testConfirmLogoutPerformsLogout() {

        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view

        presenter.confirmLogout()

        XCTAssertTrue(view.switchToSplashScreenCalled)
    }
}

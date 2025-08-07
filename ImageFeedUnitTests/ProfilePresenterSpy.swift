@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var confirmLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogoutButton() {
        didTapLogoutCalled = true
    }

    func confirmLogout() {
        confirmLogoutCalled = true
    }
}



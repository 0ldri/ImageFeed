import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    //MARK: - Setup Methods
    private var imageView: UIImageView!
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "Vector")
        
        imageView = UIImageView(image: imageSplashScreenLogo)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to find AuthViewController with identifier")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        view.backgroundColor = .ypBlack
        
        guard presentedViewController == nil else { return }
        
            if self.oauth2TokenStorage.token != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ProfileService.shared.fetchProfile { [weak self] result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let profile):
                                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                                    switch imageResult {
                                    case .success(let url):
                                        print("Avatar URL fetched")
                                    case .failure(let error):
                                        print("Avatar URL fecth failed")
                                    }
                                    self?.switchToTabBarController()
                                }
                            case .failure(let error):
                                print("Error fetching profile")
                            }
                        }
                    }
                }
            } else {
                self.presentAuthViewController()
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SplashViewController: prepare(for:) called")
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    ProfileService.shared.fetchProfile { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let profile):
                                print("Profile loaded")
                                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                                    switch imageResult {
                                    case .success(let url):
                                        print("Avatar URL fetched")
                                    case .failure(let error):
                                        print("Failed to fetch avatar")
                                    }
                                    self.switchToTabBarController()
                                }
                            case .failure(let error):
                                print("Profile loading error")
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed to fetch token")
                }
            }
        }
    }
}

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Properties
    
    var presenter: ProfilePresenterProtocol!
    
    // MARK: - UIElements
    
    let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .avatar)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .ypWhite
        return label
    }()
    
    let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypGray
        return label
    }()
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .ypWhite
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(resource: .exitButton)
        button.tintColor = .ypRed
        button.setImage(image, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter()
        presenter.view = self
        
        setupView()
        presenter.viewDidLoad()
    }
    
    // MARK: - ProfileViewControllerProtocol
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
            nameLabel.text = name
            loginNameLabel.text = loginName
            bioLabel.text = bio
        }
    
    func updateAvatar(with parameters: AvatarImageParameters) {
            avatarImage.kf.indicatorType = .activity
            avatarImage.kf.setImage(
                with: parameters.url,
                placeholder: parameters.placeholder,
                options: parameters.options
            ) { result in
                switch result {
                case .success(let value): print("Image loaded: \(value.source)")
                case .failure(let error): print("Error: \(error)")
                }
            }
        }
    
    func showLogoutConfirmation(alertModel: LogoutAlertModel) {
            let alert = UIAlertController(
                title: alertModel.title,
                message: alertModel.message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(
                title: alertModel.confirmText,
                style: .destructive,
                handler: { [weak self] _ in self?.presenter.confirmLogout() }
            ))
            
            alert.addAction(UIAlertAction(
                title: alertModel.cancelText,
                style: .cancel
            ))
            
            present(alert, animated: true)
        }
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        addSubviews()
        setupConstraints()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    @objc private func didTapLogoutButton() {
        presenter.didTapLogoutButton()
    }
    
    private func addSubviews() {
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
}

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    // MARK: - Properties
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    private let oauthService = OAuth2Service.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - UI
    
    private func configureBackButton() {
            navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
            navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
        }
    
    private func showLoginErrorAlert() {
        let alert = UIAlertController(
            title: Constants.title,
            message: Constants.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.okButton, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

    // MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        {
            UIBlockingProgressHUD.show()
            self.oauthService.fetchOAuthToken(code) { [weak self] result in
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure:
                    self.showLoginErrorAlert()
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

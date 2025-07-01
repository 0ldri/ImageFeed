import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private let userDefaults = UserDefaults.standard
    private let key = "UnsplashOAuthToken"
    
    var token: String? {
        get {
            getToken()
        }
        set {
            if let newValue = newValue {
                saveToken(newValue)
            } else {
                removeToken()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getToken() -> String? {
        userDefaults.string(forKey: key)
    }
    
    private func saveToken(_ token: String) {
        userDefaults.set(token, forKey: key)
        print("Token saved")
    }
    
    private func removeToken() {
        userDefaults.removeObject(forKey: key)
        print("Token removed")
    }
}
    


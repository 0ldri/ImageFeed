import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let keychain = KeychainWrapper.standard
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
        return keychain.string(forKey: key)
    }
    
    private func saveToken(_ token: String) {
        let isSuccess = keychain.set(token, forKey: key)
        if isSuccess {
            print("Token saved in Keychain")
        } else {
            print("Failed to save token in Keychain")
        }
    }
    
    private func removeToken() {
        let isRemoved = keychain.removeObject(forKey: key)
        if isRemoved {
            print("Token removed from Keychain")
        } else {
            print("Failed to remove token from Keychain")
        }
    }
}

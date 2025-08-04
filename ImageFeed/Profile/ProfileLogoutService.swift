import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanCookies()
        cleanProfile()
        cleanAvatar()
        cleanImages()
        cleanToken()
    }
    
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanProfile() {
        ProfileService.shared.reset()
    }
    
    private func cleanAvatar() {
        ProfileImageService.shared.reset()
    }
    
    private func cleanImages() {
        ImagesListService.shared.reset()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}


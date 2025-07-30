import Foundation

enum Constants {
    //MARK: - Unsplash api constants
    
    static let accessKey = "nVgKl53D_-3V6xZnIpeqYHaNasVrjoML4y9o9avNNhQ"
    static let secretKey = "Ss47PMMK65z27O3z5PQzfJ881HvTvH1TeMm4P_N2Jw8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Failed to create defaultBaseURL")
        }
        return url
    }()
    
    //MARK: - Unspalsh api base path
    
    static let baseURLString = "https://unspalsh.com"
    static let unspalshAuthorizedURLString = "https://unspalsh.com/oauth/authorize"
    static let baseAuthTokenPath = "/oauth/token"
    static let defaultApiBaseURLString = "https://api.unsplash.com"
    
    //MARK: - Storage
    
    static let bearerToken = "bearerToken"
    
    //MARK: - Login Error Alert
    
    static let title = "Что-то пошло не так"
    static let message = "Не удалось войти в систему"
    static let okButton = "Ок"
}


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
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
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
    
    // MARK: - AuthConfiguration
    
    struct AuthConfiguration {
        let accessKey: String
        let secretKey: String
        let redirectURI: String
        let accessScope: String
        let defaultBaseURL: URL
        let authURLString: String
        

        init(accessKey: String, secreteKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
            self.accessKey = accessKey
            self.secretKey = secreteKey
            self.redirectURI = redirectURI
            self.accessScope = accessScope
            self.defaultBaseURL = defaultBaseURL
            self.authURLString = authURLString
        }
        
        static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secreteKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     defaultBaseURL: Constants.defaultBaseURL,
                                     authURLString: Constants.unsplashAuthorizeURLString)
        }
    }


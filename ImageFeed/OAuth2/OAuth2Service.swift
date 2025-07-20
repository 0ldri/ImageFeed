import Foundation

final class OAuth2Service {
    
    // MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Properties
    
    private let session = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - API
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return nil
        }
        let urlString = "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code"
        
            guard let url = URL(string: urlString, relativeTo: baseURL) else {
                return nil
            }
            
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.urlRequestError(NSError(domain: "OAuth2Service", code: -2, userInfo: [NSLocalizedDescriptionKey: "Repeat Request"])) ))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlRequestError(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URLRequest"])) ))
            return
        }
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                switch result {
                case .success(let response):
                    self?.tokenStorage.token = response.accessToken
                    print("Token received and saved")
                    completion(.success(response.accessToken))
                case .failure(let error):
                    self?.handleFailure(error: error, completion: completion)
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func handleFailure(error: Error, completion: @escaping(Result<String, Error>) -> Void) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code):
                print("Unsplash API error. Status code: \(code)")
            case .urlRequestError:
                print("URLRequest error")
            case .urlSessionError:
                print("URLSession error")
            default:
                break
            }
        }
        completion(.failure(error))
    }
}

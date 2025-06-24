import Foundation

final class OAuth2Service {
    
    // MARK: - Properties
    
    private let session = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    
    // MARK: - API
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URLRequest"])
            print("URLRequest creation failed")
            completion(.failure(NetworkError.urlRequestError(error)))
            return
        }
        let task = session.data(for: request) { [weak self] result in
            self?.task = nil
            
            switch result {
            case .success(let data):
                self?.handleSuccess(data: data, completion: completion)
            case .failure(let error):
                self?.handleFailure(error: error, completion: completion)
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func handleSuccess(data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
            tokenStorage.token = response.accessToken
            print("Token received and saved")
            completion(.success(response.accessToken))
        } catch {
            print("Decoding failed")
            completion(.failure(NetworkError.decodingError(error)))
        }
    }
    
    private func handleFailure(error: Error, completion: @escaping(Result<String, Error>) -> Void) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code):
                print("Unsplash API error. Status code: \(code)")
            case .urlRequestError(let error):
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

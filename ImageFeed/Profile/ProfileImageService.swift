import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    func reset() {
        avatarURL = nil
        task?.cancel()
        task = nil
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        task?.cancel()
        
        guard let request = makeImageRequest(username: username) else {
            completion(.failure(NetworkError.urlRequestError(NSError(domain: "ProfileImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid username"]))))
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                
                switch result {
                case .success(let profileResult):
                        guard let avatarURL = profileResult.profileImage?.small else {
                            completion(.failure(NetworkError.decodingError(NSError(
                                domain: "ProfileImageService",
                                code: -2,
                                userInfo: [NSLocalizedDescriptionKey: "No avatar URL found"]
                            ))))
                            return
                        }
                        self?.avatarURL = avatarURL
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.didChangeNotification,
                                object: self,
                                userInfo: ["URL": avatarURL])
                        completion(.success(avatarURL))
                case .failure(let error):
                    completion(.failure(error))
                    }
                }
            }
        
        task?.resume()
        
    }
    
    private func makeImageRequest(username: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: .get,
            baseURLString: Constants.defaultApiBaseURLString
            )
    }
}

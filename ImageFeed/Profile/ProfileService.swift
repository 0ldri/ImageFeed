import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeFetchProfileRequest() else {
            completion(.failure(NetworkError.urlRequestError(NSError(domain: "ProfileService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create URLRequest"])) ))
            return
        }
        
        task?.cancel()
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                
                switch result {
                case .success(let profileResult):
                    let profile = Profile(result: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    self?.handleFailure(error: error, completion: completion)
                }
            }
        }
        task?.resume()
    }
    
    private func handleFailure(error: Error, completion: @escaping(Result<Profile, Error>) -> Void) {
        if let urlError = error as? URLError {
                print("URL Error: \(urlError)")
            } else {
                print("Unknown error: \(error)")
            }
        completion(.failure(error))
    }
    
    private func makeFetchProfileRequest() -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURLString: Constants.defaultApiBaseURLString
            )
    }
}
 

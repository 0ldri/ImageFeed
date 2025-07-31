import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private var isFetching = false
    
    private let perPage = 10
    private let session = URLSession.shared
    private let baseURL = "https://unsplash.com/"
    
    
    func fetchPhotosNextPage(completion: ((Result<[Photo], Error>) -> Void)? = nil) {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = lastLoadedPage + 1
        
        guard let request = URLRequest.makeHTTPRequest(
            path: "photos?page=\(nextPage)&per_page=\(perPage)",
            httpMethod: .get,
            baseURLString: baseURL
        ) else {
            isFetching = false
            completion?(.failure(NetworkError.invalidURL))
            return
        }
        
        task?.cancel()
        task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.task = nil
                self.isFetching = false
                
                switch result {
                case .success(let results):
                    let newPhotos = results.map {Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion?(.success(newPhotos))
                case .failure(let error):
                    self.handleFailure(error)
                    completion?(.failure(error))
                }
            }
        }
        task?.resume()
    }
    private func handleFailure(_ error: Error) {
        if let urlError = error as? URLError {
            print("URL Error")
        } else {
            print("Unknow error")
        }
    }
}

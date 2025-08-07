import UIKit

final class ImagesListService: ImagesListServiceProtocol {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private var isFetching = false
    
    private let perPage = 10
    private let session = URLSession.shared
    private let baseURL = "https://api.unsplash.com/"
    
    func reset() {
        photos = []
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = lastLoadedPage + 1
        
        guard let request = URLRequest.makeHTTPRequest(
            path: "photos?page=\(nextPage)&per_page=\(perPage)",
            httpMethod: .get,
            baseURLString: baseURL
        ) else {
            isFetching = false
            completion(.failure(NetworkError.invalidURL))
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
                    let newPhotos = results.map { Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion(.success(newPhotos))
                case .failure(let error):
                    self.handleFailure(error)
                    completion(.failure(error))
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
    func changeLike(id: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.tokenMissing))
            return
        }
        
        let method: HTTPMethod = isLike ? .post : .delete
        let path = "photos/\(id)/like"
        
        guard let request = URLRequest.makeHTTPRequest(
            path: path,
            httpMethod: method,
            baseURLString: baseURL,
        ) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        task?.cancel()
        
        task = session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                if (200...299).contains(httpResponse.statusCode) {
                    if let index = self?.photos.firstIndex(where: { $0.id == id }) {
                        var photo = self!.photos[index]
                        let updatePhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: isLike
                        )
                        self?.photos[index] = updatePhoto
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    }
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            }
        }
        task?.resume()
    }
}

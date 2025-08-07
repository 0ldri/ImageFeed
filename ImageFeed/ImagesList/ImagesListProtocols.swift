import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showError(message: String)
}

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func changeLike(id: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}


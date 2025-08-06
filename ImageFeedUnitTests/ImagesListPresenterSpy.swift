@testable import ImageFeed
import XCTest

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var photosCountReturn = 0
    var photoReturn: Photo? = nil
    var configCellCalled = false
    
    func viewDidLoad() {}
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        completion(.success([]))
    }
    
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
    
    func photosCount() -> Int {
        return photosCountReturn
    }
    
    func photo(at index: Int) -> Photo? {
        return photoReturn
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        return 100
    }
    
    @MainActor
    func configCell(_ cell: ImagesListCell, at index: Int) {
        configCellCalled = true
    }
}



import UIKit
import Kingfisher

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func photosCount() -> Int
    func photo(at index: Int) -> Photo?
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
    @MainActor func configCell(_ cell: ImagesListCell, at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private let dateFormatter: DateFormatter
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        self.dateFormatter = formatter
    }
    
    func viewDidLoad() {
        fetchPhotosNextPage { _ in }
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
           view?.showLoadingIndicator()
           
           imagesListService.fetchPhotosNextPage { [weak self] result in
               DispatchQueue.main.async {
                   self?.view?.hideLoadingIndicator()
                   completion(result)
               }
           }
       }
    
    func changeLike(for photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        view?.showLoadingIndicator()
        imagesListService.changeLike(id: photoId, isLike: isLike) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingIndicator()
                completion(result)
            }
        }
    }
    
    func photosCount() -> Int {
        return imagesListService.photos.count
    }
    
    func photo(at index: Int) -> Photo? {
        guard index >= 0 && index < imagesListService.photos.count else {
            return nil
        }
        return imagesListService.photos[index]
    }
    
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    @MainActor
    func configCell(_ cell: ImagesListCell, at index: Int) {
        guard let photo = photo(at: index) else { return }
        let placeholderImage = UIImage(named: "Stub")
       
        cell.cellImageView.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            cell.cellImageView.image = placeholderImage
        }
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImageName = photo.isLiked ? "Active" : "No Active"
        cell.likeButton.setImage(UIImage(named: likeImageName), for: .normal)
        cell.setIsLike(photo.isLiked)
    }
}




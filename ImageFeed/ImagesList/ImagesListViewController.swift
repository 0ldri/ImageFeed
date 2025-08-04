
import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    private var photos: [Photo] {
        ImagesListService.shared.photos
    }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    @objc private func updateTableViewAnimated() {
        let newPhotosCount = photos.count
        let oldCount = tableView.numberOfRows(inSection: 0)
        guard newPhotosCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newPhotosCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    // MARK: - Setup Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
                let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
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

    // MARK: - Extension

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIndentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: cell, with: indexPath)
        cell.delegate = self

        return cell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(id: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("Failed to change like")
                }
            }
        }
    }
}

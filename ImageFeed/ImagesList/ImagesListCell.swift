import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImageView: UIImageView!
    
    // MARK: - Actions
    
    @IBAction func likeButtonClicked() {
        delegate?.imagesCellDidTapLike(self)
    }
    
    // MARK: - Properties
    
    static let reuseIndentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
    }
    
    func setIsLike(_ isLiked: Bool) {
        let likeImage = UIImage(named: isLiked ? "Active" : "No Active")
        likeButton.setImage(likeImage, for: .normal)
    }
}


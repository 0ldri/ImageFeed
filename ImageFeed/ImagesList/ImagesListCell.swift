import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImageView: UIImageView!
    
    // MARK: - Properties
    
    static let reuseIndentifier = "ImagesListCell"
}


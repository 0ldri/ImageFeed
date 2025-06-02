import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImageView: UIImageView!
    
    static let reuseIndentifier = "ImagesListCell"
}


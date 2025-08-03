import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded else { return }
            loadImage()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet private var scrollView: UIScrollView!
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        if let imageURL {
            loadImage()
        }
    }
    
    // MARK: - Setup Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    private func loadImage() {
        guard let imageURL else { return }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(minZoomScale, min(maxZoomScale, max(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Error Alert
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
}

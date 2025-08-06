import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var presenter: ImagesListPresenterProtocol!
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ImagesListPresenter()
        presenter.view = self
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleImagesListUpdate(_:)),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        presenter.fetchPhotosNextPage { _ in }
    }
    
    @objc private func handleImagesListUpdate(_ notification: Notification) {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = presenter.photosCount()
        
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath,
           let photo = presenter.photo(at: indexPath.row) {
            
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - ImagesListViewControllerProtocol

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else { return }
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter.photo(at: indexPath.row) else { return 200 }
        return presenter.calculateCellHeight(for: photo, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photosCount() - 1 {
            presenter.fetchPhotosNextPage { _ in }
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photosCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIndentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        presenter.configCell(cell, at: indexPath.row)
        cell.delegate = self

        return cell
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter.photo(at: indexPath.row) else { return }
        
        presenter.changeLike(for: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success:
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure:
                self?.showError(message: "Failed to change like")
            }
        }
    }
}

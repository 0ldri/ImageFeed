@testable import ImageFeed
import XCTest

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    var showErrorCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
    
    func showError(message: String) {
        showErrorCalled = true
    }
}



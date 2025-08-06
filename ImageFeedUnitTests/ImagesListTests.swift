@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    
    func testViewDidLoadCallsFetchPhotosNextPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.setValue(presenter, forKey: "presenter")
        presenter.view = viewController as? ImagesListViewControllerProtocol
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    func testHandleImagesListUpdateInsertsRows() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()
        presenter.photosCountReturn = 5
        presenter.view = viewController
        viewController.updateTableViewAnimated(oldCount: 0, newCount: 5)
        
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
    
    func testShowAndHideLoadingIndicator() {
        let viewController = ImagesListViewControllerSpy()
        
        viewController.showLoadingIndicator()
        viewController.hideLoadingIndicator()
        
        XCTAssertTrue(viewController.showLoadingIndicatorCalled)
        XCTAssertTrue(viewController.hideLoadingIndicatorCalled)
    }
    
    func testShowError() {
        let viewController = ImagesListViewControllerSpy()
        viewController.showError(message: "Test Error")
        XCTAssertTrue(viewController.showErrorCalled)
    }
}



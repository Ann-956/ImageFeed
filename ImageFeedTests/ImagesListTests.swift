import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let presenter = ImagesListViewPresenterSpy()
        let viewController = ImagesListViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        viewController.simulateViewDidLoad()
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterFetchPhotosNextPage() {
        // given
        let presenter = ImagesListViewPresenterSpy()
        
        // when
        presenter.willDisplayCell(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    func testPresenterChangeLike() {
        // given
        let presenter = ImagesListViewPresenterSpy()
        let indexPath = IndexPath(row: 0, section: 0)
        
        // when
        presenter.changeLike(for: indexPath) { _ in }
        
        // then
        XCTAssertTrue(presenter.changeLikeCalled)
        XCTAssertEqual(presenter.changeLikeIndexPath, indexPath)
    }
    
    func testViewControllerCallsUpdateTableViewAnimated() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter(view: viewController)
        viewController.presenter = presenter
        
        // when
        viewController.updateTableViewAnimated()
        
        // then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
}

// MARK: - Spies


final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?
    
    var updateTableViewAnimatedCalled = false
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    func simulateViewDidLoad() {
        self.presenter?.viewDidLoad()
    }
}

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var photos: [Photos] = []
    var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var changeLikeIndexPath: IndexPath?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(for indexPath: IndexPath, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikeIndexPath = indexPath
        completion(.success(()))
    }
    
    func configureCell(for indexPath: IndexPath) -> (imageURL: URL?, formattedDate: String, isLiked: Bool) {
        return (nil, "Test Date", false)
    }
    
    func checkForUpdates() {}
    
    func getNewIndexPaths() -> [IndexPath]? {
        return nil
    }
}


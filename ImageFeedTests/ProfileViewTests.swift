@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        presenter.view = viewController

        // when
        viewController.simulateViewDidLoad()

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled, "viewDidLoad should have been called on presenter.")
    }

    func testPresenterCallsUpdateUI() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        presenter.view = viewController

        // when
        presenter.updateUIInfo()

        // then
        XCTAssertTrue(viewController.updateUICalled, "updateUI should have been called on view.")
    }

    func testPresenterCallsUpdateAvatar() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        presenter.view = viewController

        // when
        viewController.simulateViewDidLoad() // Триггерим viewDidLoad
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)

        // then
        XCTAssertTrue(viewController.updateAvatarCalled, "updateAvatar should have been called on view.")
    }

    func testViewControllerUpdatesUI() {
        // given
        let presenter = ProfileViewPresenterSpy()
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        presenter.view = viewController

        // when
        presenter.updateUIInfo()

        // then
        XCTAssertEqual(viewController.userName, "John Doe", "User name should be updated.")
        XCTAssertEqual(viewController.userEmail, "john_doe", "User email should be updated.")
        XCTAssertEqual(viewController.userBio, "This is a sample bio.", "User bio should be updated.")
    }
}

// MARK: - Spies

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var updateAvatarCalled = false
    var updateUICalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
        updateUIInfo() 
        subscribeToAvatarChanges()
    }

    func updateUIInfo() {
        updateUICalled = true
        view?.updateUI(name: "John Doe", loginName: "john_doe", bio: "This is a sample bio.")
    }

    func handleLogout() {}

    func getAvatarURL() -> String? {
        return "http://example.com/avatar.jpg"
    }

    func subscribeToAvatarChanges() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.view?.updateAvatar()
        }
    }
}

// MARK: - ProfileViewControllerSpy

final class ProfileViewControllerSpy: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var updateUICalled = false
    var updateAvatarCalled = false
    var userName: String?
    var userEmail: String?
    var userBio: String?

    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func simulateViewDidLoad() {
        self.loadViewIfNeeded()
        self.presenter?.viewDidLoad()
    }

    func updateUI(name: String, loginName: String, bio: String) {
        updateUICalled = true
        userName = name
        userEmail = loginName
        userBio = bio
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }
}

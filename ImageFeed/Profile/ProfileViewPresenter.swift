import Foundation


protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func handleLogout()
    func getAvatarURL() -> String?
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    var profileImageServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        updateUIInfo()
        subscribeToAvatarChanges()
    }
    
    func updateUIInfo() {
        guard let profile = ProfileService.shared.profileInfo else { return }
        view?.updateUI(name: profile.name ?? "", loginName: profile.loginName ?? "", bio: profile.bio ?? "")
        
    }
    
    func handleLogout() {
        ProfileLogoutService.shared.logout()
    }
    
    func getAvatarURL() -> String? {
        return ProfileImageService.shared.avatarURL
    }
    
    func subscribeToAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.view?.updateAvatar()
            }
        view?.updateAvatar()
    }
    
    
    
}

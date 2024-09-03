import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service.shared
    private var didSwitchToTabBarController = false
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    private let logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor.ypBlack
        view.addSubview(logoView)
        setupConstraints()

        if let token = storage.token {
            loadProfile(token)
        } else {
            showAuthenticationScreen()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 75),
            logoView.heightAnchor.constraint(equalToConstant: 78),
            
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func switchToTabBarController() {
        guard !didSwitchToTabBarController else { return }
        didSwitchToTabBarController = true
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func loadProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    if let username = profile.userName {
                        self.profileImageService.fetchProfileImageUrl(username: username) { _ in}
                    }
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                    break
                }
            }
        }
    }
    
    private func showAuthenticationScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthorizationViewController") as? AuthorizationViewController,
              let navigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController
        else {
            fatalError("AuthorizationViewController or NavigationController not found in Main storyboard")
        }
        authViewController.delegate = self
        navigationController.viewControllers = [authViewController]
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthorizationViewControllerDelegate {
    func didAuthenticate(_ vc: AuthorizationViewController) {
        vc.dismiss(animated: true)
            
        guard let token = self.storage.token else { return }
        loadProfile(token)
    }
    
        
}

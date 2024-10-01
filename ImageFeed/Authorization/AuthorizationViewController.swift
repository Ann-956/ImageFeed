import UIKit

protocol AuthorizationViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthorizationViewController)
}

final class AuthorizationViewController: UIViewController {
    
    @IBOutlet private weak var loginButton: UIButton!
    private weak var delegate: AuthorizationViewControllerDelegate?
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "NavBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "NavBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.accessibilityIdentifier = "Authenticate"
        configureBackButton()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthorizationViewController: WebViewViewControllerDelegate {
   func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(with: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case.success(let token):
                print("Token received: \(token)")
                OAuth2TokenStorage().token = token
                vc.dismiss(animated: true) {
                    self.delegate?.didAuthenticate(self)
                }
            case.failure:
                self.showErrorAlert()
            }
        }
    }
    
   func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

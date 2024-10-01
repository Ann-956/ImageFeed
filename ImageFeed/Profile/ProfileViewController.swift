import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateUI(name: String, loginName: String, bio: String)
    func updateAvatar()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfileViewPresenterProtocol?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackViewImage: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let stackViewInfo: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        presenter = ProfileViewPresenter(view: self)
        presenter?.viewDidLoad()
        
        exitButton.accessibilityIdentifier = "ExitButton"
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAvatarImageView()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = presenter?.getAvatarURL(),
            let url = URL(string: profileImageURL)
        else {
            print("Invalid avatar URL")
            return
        }
        
        let options: KingfisherOptionsInfo = [
            .cacheOriginalImage,
            .transition(.fade(0.2))
        ]
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Placeholder"),
            options: options
        )
    }
    
    @objc private func didTapExitButton() {
        showAlertExit()
    }
    
    private func showAlertExit() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter?.handleLogout()
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    private func setupAvatarImageView() {
        let width = avatarImageView.bounds.size.width
        avatarImageView.layer.cornerRadius = width / 2
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        
        [avatarImageView, exitButton].forEach{
            stackViewImage.addArrangedSubview($0)
        }
        [userNameLabel, userEmailLabel, userDescriptionLabel].forEach{
            stackViewInfo.addArrangedSubview($0)
        }
        [stackViewImage, stackViewInfo].forEach{
            view.addSubview($0)
        }
        
        avatarImageView.image = UIImage(named: "Avatar")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackViewImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackViewImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stackViewImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            
            stackViewInfo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackViewInfo.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackViewInfo.topAnchor.constraint(equalTo: stackViewImage.bottomAnchor, constant: 8),
        ])
    }
    
    func updateUI(name: String, loginName: String, bio: String) {
        userNameLabel.text = name
        userEmailLabel.text = loginName
        userDescriptionLabel.text = bio
    }
}

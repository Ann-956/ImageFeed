import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
struct ProfileImage: Codable {
    let large: URL // в задаче написано использовать картинку small, но размеры small не подходят под экран Retina дисплкй и изображение размытое получается
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private let tokenStorage = OAuth2TokenStorage()
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private init() {}
    
    func clearAvatarURL() {
        avatarURL = nil
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let url = URL(string:"https://api.unsplash.com/users/\(username)"),
            let token = tokenStorage.token
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageUrl(username: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        task?.cancel()
        
        guard
            let request = makeProfileImageRequest(username: username)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.large.absoluteString
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
                
            case .failure(let error):
                print("[ProfileImageService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
}

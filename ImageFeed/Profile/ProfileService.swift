import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private let tokenStorage = OAuth2TokenStorage()
    private (set) var profileInfo: Profile?
    private var task: URLSessionTask?
    private init() {}
    private let urlSession = URLSession.shared

    
    private func makeProfileRequest() -> URLRequest? {
        guard
            let url = URL(string: "https://api.unsplash.com/me"),
            let token = tokenStorage.token
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping(Result<Profile, Error>) -> Void) {
        
        task?.cancel()
        
        guard let request = makeProfileRequest() else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            
            guard let self = self else {return}
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profileInfo = profile
                completion(.success(profile))
            case .failure(let error):
                print("[ProfileService]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    
        task?.resume()
          
    }
}

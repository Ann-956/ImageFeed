import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            let baseURL = URL(string: "https://unsplash.com"),
            let url = URL(
                string: "/oauth/token"
                + "?client_id=\(Constaints.accessKey)"
                + "&client_secret=\(Constaints.secretKey)"
                + "&redirect_uri=\(Constaints.redirectURI)"
                + "&code=\(code)"
                + "&grant_type=authorization_code",
                relativeTo: baseURL
            )
        else {
           assertionFailure("Failed to create URL")
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
        
    }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.task = nil
                self.lastCode = nil
                
                
                switch result {
                    case .success(let tokenResponse):
                        self.tokenStorage.token = tokenResponse.accessToken
                        completion(.success(tokenResponse.accessToken))
                    case .failure(let error):
                        print("[OAuth2Service]: \(error.localizedDescription)")
                        completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }
}




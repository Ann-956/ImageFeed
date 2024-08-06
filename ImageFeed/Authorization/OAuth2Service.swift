import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private init() {}
    
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
            print("Failed to create URL for OAuth token request")
            return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        self.tokenStorage.token = tokenResponse.accessToken
                        completion(.success(tokenResponse.accessToken))
                    } catch {
                        print("Decoding error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    if let urlError = error as? URLError {
                        print("Network error: \(urlError)")
                    } else if let networkError = error as? NetworkError {
                        switch networkError {
                        case .httpStatusCode(let statusCode):
                            print("HTTP Status Code Error: \(statusCode)")
                        case .urlRequestError(let underlyingError):
                            print("URL Request Error: \(underlyingError)")
                        case .urlSessionError:
                            print("URL Session Error")
                        }
                    } else {
                        print("Unknown error: \(error)")
                    }
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}


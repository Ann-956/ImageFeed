import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
    
}



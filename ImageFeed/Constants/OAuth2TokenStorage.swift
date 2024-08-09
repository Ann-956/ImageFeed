import Foundation

class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2BearerToken"
    
    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
    
    func hasToken() -> Bool {
            return token != nil
        }
}

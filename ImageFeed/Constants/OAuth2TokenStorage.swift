import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    private let tokenKey = "OAuth2BearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newToken = newValue {
                let isSuccess = KeychainWrapper.standard.set(newToken, forKey: tokenKey)
                if !isSuccess {
                    print("Ошибка при сохранении токена в Keychain")
                }
            } else {
                let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !removeSuccessful {
                    print("Ошибка при удалении токена из Keychain")
                }
            }
        }
        
    }
    
    func removeToken() {
            KeychainWrapper.standard.removeObject(forKey: tokenKey)
        }
}

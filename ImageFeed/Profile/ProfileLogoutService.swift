import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    
    func logout() {
        OAuth2TokenStorage().removeToken()
        cleanCookies()
        clearProfileData()
        redirectToInitialScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearProfileData() {
        ProfileService.shared.clearProfileInfo()
        ProfileImageService.shared.clearAvatarURL()
        ImagesListService.shared.clearImages()
    }
    
    private func redirectToInitialScreen() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            print("No key window found")
            return
        }
        
        let splashController = SplashViewController()
        
        window.rootViewController = splashController
        window.makeKeyAndVisible()
    }
    
}

import Foundation

enum Constaints {
    static let accessKey = "-tvtXvmuyASAAQvCPP5QZDJ1ykxY78VEedJghkFJDEE"
    static let secretKey = "5ZuggQSr5oyCYU-D6V8xrNWY9cZ3_CrgUpkqRoTHHN4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constaints.accessKey,
                                 secretKey: Constaints.secretKey,
                                 redirectURI: Constaints.redirectURI,
                                 accessScope: Constaints.accessScope,
                                 authURLString: Constaints.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constaints.defaultBaseURL)
    }
}

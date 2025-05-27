import Foundation

/// Class responsible for managing authentication tokens 
class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"
    
    private init() {}
    
    // MARK: - Token Management
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: refreshTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    }
}

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

/// Comprehensive AuthService that handles both Firebase and API authentication
class AuthService {
    // Singleton instance
    static let shared: AuthService = {
        return AuthService()
    }()
    
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    private let refreshTokenKey = "refresh_token"
    
    private init() {}
    
    // MARK: - Authentication
    
    /// Sign in with email and password using Firebase
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result: AuthDataResult?, error: Error?) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = result else {
                completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid auth result"])))
                return
            }
            
            let uid = authResult.user.uid
            
            // Get user profile
            self?.getUserProfile(uid: uid, completion: completion)
        }
    }
    
    /// Register a new user with Firebase
    func register(email: String, password: String, name: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result: AuthDataResult?, error: Error?) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let authResult = result else {
                completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid auth result"])))
                return
            }
            
            let uid = authResult.user.uid
            
            // Create user profile
            let newUser = User(
                id: uid,
                firstName: name.components(separatedBy: " ").first ?? name,
                lastName: name.components(separatedBy: " ").last ?? "",
                email: email,
                phoneNumber: nil,
                profileImageUrl: nil,
                role: .customer,
                location: nil,
                isVerified: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // Save user to Firestore
            FirestoreService.shared.saveUser(newUser) { [weak self] (error: Error?) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                self?.saveCurrentUser(newUser)
                completion(.success(newUser))
            }
        }
    }
    
    /// Get user profile from Firestore
    private func getUserProfile(uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        FirestoreService.shared.getUser(id: uid) { (user: User?, error: Error?) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = user {
                self.saveCurrentUser(user)
                completion(.success(user))
            } else {
                completion(.failure(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
            }
        }
    }
    
    /// Sign out the current user
    func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            clearCurrentUser()
            clearTokens()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    /// Check if a user is signed in
    func isUserSignedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    /// Get the current Firebase user ID
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
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
    
    // MARK: - User Management
    func saveCurrentUser(_ user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: userKey)
        }
    }
    
    func getCurrentUser() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: userKey) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            return user
        } catch {
            print("Error decoding user: \(error)")
            return nil
        }
    }
    
    func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    // MARK: - Password Reset
    
    /// Send password reset email
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error: Error?) in
            completion(error)
        }
    }
    
    // MARK: - Profile Updates
    
    /// Update user profile
    func updateUserProfile(user: User, completion: @escaping (Error?) -> Void) {
        FirestoreService.shared.saveUser(user) { [weak self] (error: Error?) in
            if error == nil {
                self?.saveCurrentUser(user)
            }
            completion(error)
        }
    }
    
    // MARK: - API Authentication Methods
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        NetworkService.shared.request(endpoint: "/auth/login", 
                                     method: .post,
                                     parameters: parameters) { (result: Result<AuthResponse, NetworkError>) in
            switch result {
            case .success(let response):
                self.saveToken(response.token)
                if let refreshToken = response.refreshToken {
                    self.saveRefreshToken(refreshToken)
                }
                self.saveCurrentUser(response.user)
                completion(.success(response.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func register(firstName: String, lastName: String, email: String, password: String, 
                 phoneNumber: String?, role: UserRole, completion: @escaping (Result<User, Error>) -> Void) {
        
        var parameters: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "password": password,
            "role": role.rawValue
        ]
        
        if let phone = phoneNumber {
            parameters["phoneNumber"] = phone
        }
        
        NetworkService.shared.request(endpoint: "/auth/register", 
                                     method: .post,
                                     parameters: parameters) { (result: Result<AuthResponse, NetworkError>) in
            switch result {
            case .success(let response):
                self.saveToken(response.token)
                if let refreshToken = response.refreshToken {
                    self.saveRefreshToken(refreshToken)
                }
                self.saveCurrentUser(response.user)
                completion(.success(response.user))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        // If we need to tell the server about logout
        if let _ = getToken() {
            NetworkService.shared.request(endpoint: "/auth/logout",
                                         method: .post) { (result: Result<EmptyResponse, NetworkError>) in
                // Regardless of the response, clear local data
                self.clearTokens()
                self.clearCurrentUser()
                completion(true)
            }
        } else {
            // No token, just clear local data
            self.clearTokens()
            self.clearCurrentUser()
            completion(true)
        }
    }
}

// MARK: - Response Types
struct AuthResponse: Codable {
    let token: String
    let refreshToken: String?
    let user: User
}
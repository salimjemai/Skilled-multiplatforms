import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    // Current user data
    var currentUser: User?
    
    // Fetch current user data from Firestore
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "UserManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists, let userData = document.data() else {
                completion(nil, NSError(domain: "UserManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User document not found"]))
                return
            }
            
            // Convert Firestore Timestamp objects to strings before serialization
            var processedUserData = [String: Any]()
            
            for (key, value) in userData {
                if let timestamp = value as? Timestamp {
                    // Convert timestamp to milliseconds since epoch
                    processedUserData[key] = timestamp.dateValue().timeIntervalSince1970 * 1000
                } else {
                    processedUserData[key] = value
                }
            }
            
            // Manual conversion from dictionary to User
            let id = (processedUserData["id"] as? String) ?? userId
            guard let email = processedUserData["email"] as? String,
                  let firstName = processedUserData["firstName"] as? String,
                  let lastName = processedUserData["lastName"] as? String,
                  let roleString = processedUserData["role"] as? String,
                  let role = UserRole(rawValue: roleString),
                  let isVerified = processedUserData["isVerified"] as? Bool else {
                completion(nil, NSError(domain: "UserManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid user data format"]))
                return
            }
            
            // Handle dates
            let createdAt: Date
            if let createdAtTimestamp = userData["createdAt"] as? Timestamp {
                createdAt = createdAtTimestamp.dateValue()
            } else if let createdAtDouble = processedUserData["createdAt"] as? Double {
                createdAt = Date(timeIntervalSince1970: createdAtDouble / 1000)
            } else {
                createdAt = Date()
            }
            
            let updatedAt: Date
            if let updatedAtTimestamp = userData["updatedAt"] as? Timestamp {
                updatedAt = updatedAtTimestamp.dateValue()
            } else if let updatedAtDouble = processedUserData["updatedAt"] as? Double {
                updatedAt = Date(timeIntervalSince1970: updatedAtDouble / 1000)
            } else {
                updatedAt = Date()
            }
            
            // Create user object
            let user = User(
                id: id,
                firstName: firstName,
                lastName: lastName,
                email: email,
                phoneNumber: processedUserData["phoneNumber"] as? String,
                profileImageUrl: processedUserData["profileImageUrl"] as? String,
                role: role,
                location: nil, // We would need to parse location separately
                isVerified: isVerified,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            
            self.currentUser = user
            completion(user, nil)
        }
    }
}
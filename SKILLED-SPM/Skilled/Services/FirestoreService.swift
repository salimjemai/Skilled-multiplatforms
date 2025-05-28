import Foundation
import Firebase
import FirebaseFirestore

class FirestoreService {
    
    // MARK: - Shared Instance
    static let shared = FirestoreService()
    
    // MARK: - Properties
    private let db = Firestore.firestore()
    
    // Collection references
    private let usersRef: CollectionReference
    private let providersRef: CollectionReference
    private let servicesRef: CollectionReference
    private let bookingsRef: CollectionReference
    private let reviewsRef: CollectionReference
    
    // MARK: - Initialization
    private init() {
        // Initialize collection references
        usersRef = db.collection("users")
        providersRef = db.collection("serviceProviders")
        servicesRef = db.collection("services")
        bookingsRef = db.collection("bookings")
        reviewsRef = db.collection("reviews")
        
        // We don't need to reconfigure Firestore settings here
        // since they're already set in AppDelegate
        print("FirestoreService initialized with collections")
    }
    
    // MARK: - User Methods
    
    /// Save user to Firestore
    func saveUser(_ user: User, completion: @escaping (Error?) -> Void) {
        // Use the toDictionary method from the User model
        let userData = user.toDictionary()
        
        // Use direct dictionary approach instead of Codable
        usersRef.document(user.id).setData(userData) { error in
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
                completion(error)
            } else {
                print("User successfully saved to Firestore")
                completion(nil)
            }
        }
    }
    
    /// Get user by ID
    func getUser(id: String, completion: @escaping (User?, Error?) -> Void) {
        usersRef.document(id).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("User document does not exist for ID: \(id)")
                completion(nil, NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            do {
                // Try to decode directly using Firestore's built-in decoder
                if let user = try? snapshot.data(as: User.self) {
                    print("Successfully retrieved user via Codable")
                    completion(user, nil)
                    return
                }
                
                // Fallback to manual conversion if Codable fails
                guard let data = snapshot.data() else {
                    print("Empty user data for ID: \(id)")
                    completion(nil, NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Empty user data"]))
                    return
                }
                
                // Manual conversion from dictionary to User
                guard let email = data["email"] as? String,
                      let firstName = data["firstName"] as? String,
                      let lastName = data["lastName"] as? String,
                      let roleString = data["role"] as? String,
                      let role = UserRole(rawValue: roleString),
                      let isVerified = data["isVerified"] as? Bool,
                      let createdAt = data["createdAt"] as? Timestamp,
                      let updatedAt = data["updatedAt"] as? Timestamp else {
                    print("Invalid user data format for ID: \(id)")
                    completion(nil, NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid user data format"]))
                    return
                }
                
                let user = User(
                    id: id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phoneNumber: data["phoneNumber"] as? String,
                    profileImageUrl: data["profileImageUrl"] as? String,
                    role: role,
                    location: nil, // We would need to parse location if needed
                    isVerified: isVerified,
                    createdAt: createdAt.dateValue(),
                    updatedAt: updatedAt.dateValue()
                )
                
                print("Successfully retrieved user via manual parsing")
                completion(user, nil)
            } catch {
                print("Error parsing user data: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Service Provider Methods
    
    /// Save service provider to Firestore
    func saveServiceProvider(_ provider: ServiceProvider, completion: @escaping (Error?) -> Void) {
        do {
            try providersRef.document(provider.id).setData(from: provider) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    /// Get service provider by ID
    func getServiceProvider(id: String, completion: @escaping (ServiceProvider?, Error?) -> Void) {
        providersRef.document(id).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let provider = try snapshot.data(as: ServiceProvider.self)
                completion(provider, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    /// Get service providers by trade category
    func getServiceProviders(forCategory category: TradeCategory, completion: @escaping ([ServiceProvider]?, Error?) -> Void) {
        providersRef
            .whereField("tradeCategories", arrayContains: category.rawValue)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let providers = try snapshot.documents.compactMap { try $0.data(as: ServiceProvider.self) }
                    completion(providers, nil)
                } catch {
                    completion(nil, error)
                }
            }
    }
    
    // MARK: - Trade Service Methods
    
    /// Save trade service to Firestore
    func saveTradeService(_ service: TradeService, completion: @escaping (Error?) -> Void) {
        do {
            try servicesRef.document(service.id).setData(from: service) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    /// Get services for a service provider
    func getServices(forProviderId providerId: String, completion: @escaping ([TradeService]?, Error?) -> Void) {
        servicesRef
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let services = try snapshot.documents.compactMap { try $0.data(as: TradeService.self) }
                    completion(services, nil)
                } catch {
                    completion(nil, error)
                }
            }
    }
    
    // MARK: - Booking Methods
    
    /// Save booking to Firestore
    func saveBooking(_ booking: Booking, completion: @escaping (Error?) -> Void) {
        // Use the toDictionary method instead of Codable
        let bookingData = booking.toDictionary()
        
        bookingsRef.document(booking.id).setData(bookingData) { error in
            completion(error)
        }
    }
    
    /// Get bookings for a user
    func getBookings(forUserId userId: String, completion: @escaping ([Booking]?, Error?) -> Void) {
        bookingsRef
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                let bookings = snapshot.documents.compactMap { document in
                    return Booking.fromDictionary(document.data())
                }
                completion(bookings, nil)
            }
    }
    
    /// Get bookings for a service provider
    func getBookings(forProviderId providerId: String, completion: @escaping ([Booking]?, Error?) -> Void) {
        bookingsRef
            .whereField("providerId", isEqualTo: providerId)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                let bookings = snapshot.documents.compactMap { document in
                    return Booking.fromDictionary(document.data())
                }
                completion(bookings, nil)
            }
    }
    
    // MARK: - Review Methods
    
    /// Save review to Firestore
    func saveReview(_ review: Review, completion: @escaping (Error?) -> Void) {
        do {
            try reviewsRef.document(review.id).setData(from: review) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    /// Get reviews for a service provider
    func getReviews(forProviderId providerId: String, completion: @escaping ([Review]?, Error?) -> Void) {
        reviewsRef
            .whereField("providerUserId", isEqualTo: providerId)
            .getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    completion(nil, error)
                    return
                }
                
                do {
                    let reviews = try snapshot.documents.compactMap { try $0.data(as: Review.self) }
                    completion(reviews, nil)
                } catch {
                    completion(nil, error)
                }
            }
    }
    
    // MARK: - User Email Check
    
    /// Check if a user with the given email exists in Firestore
    func checkUserExists(withEmail email: String, completion: @escaping (Bool, Error?) -> Void) {
        // Add logging to track the flow
        print("Checking if user exists with email: \(email)")
        
        usersRef
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking for user existence: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Null snapshot returned when checking for user")
                    completion(false, nil)
                    return
                }
                
                let exists = !snapshot.documents.isEmpty
                print("User with email \(email) exists: \(exists)")
                completion(exists, nil)
            }
    }
    
    // MARK: - Helper Methods
    
    /// Generate a new document ID
    func generateID() -> String {
        return db.collection("_").document().documentID
    }
}

import Foundation
import FirebaseFirestore // Import for Timestamp type

enum UserRole: String, Codable {
    case customer
    case provider
    case admin
}

struct User: Codable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String?
    var profileImageUrl: String?
    var role: UserRole
    var location: Location?
    var isVerified: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Provider-specific properties
    var businessName: String?
    var businessDescription: String?
    var yearsOfExperience: Int?
    var servicesOffered: [String]?
    var ratings: Double?
    var reviewCount: Int?
    var isAvailableForHire: Bool?
    
    // Default memberwise initializer
    init(id: String, 
         firstName: String, 
         lastName: String, 
         email: String, 
         phoneNumber: String? = nil, 
         profileImageUrl: String? = nil, 
         role: UserRole, 
         location: Location? = nil, 
         isVerified: Bool, 
         createdAt: Date, 
         updatedAt: Date,
         businessName: String? = nil,
         businessDescription: String? = nil,
         yearsOfExperience: Int? = nil,
         servicesOffered: [String]? = nil,
         ratings: Double? = nil,
         reviewCount: Int? = nil,
         isAvailableForHire: Bool? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.role = role
        self.location = location
        self.isVerified = isVerified
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        // Initialize provider-specific properties
        self.businessName = businessName
        self.businessDescription = businessDescription
        self.yearsOfExperience = yearsOfExperience
        self.servicesOffered = servicesOffered
        self.ratings = ratings
        self.reviewCount = reviewCount
        self.isAvailableForHire = isAvailableForHire
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    // Convert User to Dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "role": role.rawValue,
            "isVerified": isVerified,
            "createdAt": Timestamp(date: createdAt),  // Convert Date to Firestore Timestamp
            "updatedAt": Timestamp(date: updatedAt)   // Convert Date to Firestore Timestamp
        ]
        
        if let phoneNumber = phoneNumber {
            dict["phoneNumber"] = phoneNumber
        }
        
        if let profileImageUrl = profileImageUrl {
            dict["profileImageUrl"] = profileImageUrl
        }
        
        if let location = location {
            dict["location"] = [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "address": location.address
            ]
        }
        
        // Add provider-specific properties if they exist
        if role == .provider {
            if let businessName = businessName {
                dict["businessName"] = businessName
            }
            
            if let businessDescription = businessDescription {
                dict["businessDescription"] = businessDescription
            }
            
            if let yearsOfExperience = yearsOfExperience {
                dict["yearsOfExperience"] = yearsOfExperience
            }
            
            if let servicesOffered = servicesOffered {
                dict["servicesOffered"] = servicesOffered
            }
            
            if let ratings = ratings {
                dict["ratings"] = ratings
            }
            
            if let reviewCount = reviewCount {
                dict["reviewCount"] = reviewCount
            }
            
            if let isAvailableForHire = isAvailableForHire {
                dict["isAvailableForHire"] = isAvailableForHire
            }
        }
        
        return dict
    }
    
    // Initialize User from Firestore Dictionary
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let email = dictionary["email"] as? String,
              let roleString = dictionary["role"] as? String,
              let role = UserRole(rawValue: roleString),
              let isVerified = dictionary["isVerified"] as? Bool
        else {
            return nil
        }
        
        // Handle date fields from Firestore (could be Date or Timestamp)
        let createdDate: Date
        if let timestamp = dictionary["createdAt"] as? Timestamp {
            createdDate = timestamp.dateValue()
        } else if let date = dictionary["createdAt"] as? Date {
            createdDate = date
        } else {
            return nil
        }
        
        let updatedDate: Date
        if let timestamp = dictionary["updatedAt"] as? Timestamp {
            updatedDate = timestamp.dateValue()
        } else if let date = dictionary["updatedAt"] as? Date {
            updatedDate = date
        } else {
            return nil
        }
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.role = role
        self.isVerified = isVerified
        self.createdAt = createdDate
        self.updatedAt = updatedDate
        
        // Initialize provider-specific properties if the user is a provider
        if role == .provider {
            self.businessName = dictionary["businessName"] as? String
            self.businessDescription = dictionary["businessDescription"] as? String
            self.yearsOfExperience = dictionary["yearsOfExperience"] as? Int
            self.servicesOffered = dictionary["servicesOffered"] as? [String]
            self.ratings = dictionary["ratings"] as? Double
            self.reviewCount = dictionary["reviewCount"] as? Int
            self.isAvailableForHire = dictionary["isAvailableForHire"] as? Bool
        }
        
        if let locationDict = dictionary["location"] as? [String: Any],
           let latitude = locationDict["latitude"] as? Double,
           let longitude = locationDict["longitude"] as? Double,
           let address = locationDict["address"] as? String {
            self.location = Location(latitude: latitude, longitude: longitude, address: address, city: "Austin", state: "TX", zipCode: "78704", country: "US")
        } else {
            self.location = nil
        }
    }
}

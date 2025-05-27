import Foundation

struct ServiceProvider: Codable {
    let id: String
    let userId: String
    var businessName: String
    var description: String
    var services: [String]? // Store just the TradeService IDs instead of the full objects
    var averageRating: Double
    var totalReviews: Int
    var tradeCategories: [String] // Store trade categories as strings
    var yearsOfExperience: Int
    var licenses: [License]?
    var insuranceVerified: Bool
    var backgroundCheckVerified: Bool
    var availableTimes: [AvailabilityTime]?
    var profileCompleted: Bool
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Modified initializer to use strings for services and tradeCategories
    init(id: String, userId: String, businessName: String, description: String, 
         services: [String]? = nil, averageRating: Double, totalReviews: Int, 
         tradeCategories: [String], yearsOfExperience: Int, licenses: [License]? = nil, 
         insuranceVerified: Bool, backgroundCheckVerified: Bool, availableTimes: [AvailabilityTime]? = nil, 
         profileCompleted: Bool, isActive: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.businessName = businessName
        self.description = description
        self.services = services
        self.averageRating = averageRating
        self.totalReviews = totalReviews
        self.tradeCategories = tradeCategories
        self.yearsOfExperience = yearsOfExperience
        self.licenses = licenses
        self.insuranceVerified = insuranceVerified
        self.backgroundCheckVerified = backgroundCheckVerified
        self.availableTimes = availableTimes
        self.profileCompleted = profileCompleted
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct License: Codable {
    let id: String
    var name: String
    var licenseNumber: String
    var issuingAuthority: String
    var expirationDate: Date
    var verificationStatus: VerificationStatus
    var documentUrl: String?
}

enum VerificationStatus: String, Codable {
    case pending
    case verified
    case rejected
}

struct AvailabilityTime: Codable {
    var dayOfWeek: DayOfWeek
    var startTime: String // Format: "HH:MM"
    var endTime: String // Format: "HH:MM"
}

enum DayOfWeek: String, Codable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

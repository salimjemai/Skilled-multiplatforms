import Foundation

struct ServiceProvider: Codable {
    let id: String
    let userId: String
    let businessName: String
    let description: String
    let services: [TradeService]?
    let averageRating: Double
    let totalReviews: Int
    let tradeCategories: [String]
    let yearsOfExperience: Int
    let licenses: [String]?
    let insuranceVerified: Bool
    let backgroundCheckVerified: Bool
    let availableTimes: [String]?
    let profileCompleted: Bool
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Additional properties to match User model
    var email: String = ""
    var phoneNumber: String?
    var profileImageUrl: String?
    var location: Location?
    var isVerified: Bool = false
}
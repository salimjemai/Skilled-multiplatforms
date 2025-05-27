import Foundation

struct Review: Codable {
    let id: String
    let userId: String
    let providerUserId: String
    let bookingId: String?
    var rating: Int // 1-5 stars
    var comment: String?
    var responseFromProvider: ReviewResponse?
    var isVerifiedBooking: Bool
    var createdAt: Date
    var updatedAt: Date
}

struct ReviewResponse: Codable {
    let id: String
    let reviewId: String
    let providerUserId: String
    var responseText: String
    var createdAt: Date
}
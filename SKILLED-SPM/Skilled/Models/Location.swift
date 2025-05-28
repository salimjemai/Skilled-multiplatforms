import Foundation

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var address: String
    var addressLine2: String?
    var city: String
    var state: String
    var zipCode: String
    var country: String
}

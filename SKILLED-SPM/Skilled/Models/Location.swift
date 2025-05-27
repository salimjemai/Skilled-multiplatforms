import Foundation

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
}

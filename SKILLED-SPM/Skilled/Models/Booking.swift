import Foundation

struct Booking: Codable {
    let id: String
    let customerId: String
    let providerId: String
    let serviceId: String
    var status: BookingStatus
    var scheduledStartTime: Date
    var scheduledEndTime: Date?
    var actualStartTime: Date?
    var actualEndTime: Date?
    var location: Location
    var specialInstructions: String?
    var price: BookingPrice
    var paymentStatus: PaymentStatus
    var paymentMethod: PaymentMethod?
    var cancellationReason: String?
    var cancellationTime: Date?
    var cancellationBy: String?
    var createdAt: Date
    var updatedAt: Date
}

struct BookingPrice: Codable {
    var originalAmount: Double
    var discountAmount: Double?
    var taxAmount: Double?
    var serviceCharge: Double?
    var totalAmount: Double
    var currency: String // e.g., "USD"
}

enum BookingStatus: String, Codable {
    case pending // Initial request
    case accepted // Provider accepted
    case confirmed // Payment confirmed
    case inProgress // Service in progress
    case completed // Service finished
    case cancelled // Booking cancelled
    case rejected // Provider rejected
    case noShow // Customer didn't show up
}

enum PaymentStatus: String, Codable {
    case pending
    case authorized
    case paid
    case partiallyRefunded
    case refunded
    case failed
}

enum PaymentMethod: String, Codable {
    case creditCard
    case debitCard
    case applePay
    case paypal
    case cash
    case bankTransfer
}
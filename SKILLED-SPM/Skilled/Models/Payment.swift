import Foundation
import FirebaseFirestore

enum PaymentStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
    
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }
}

enum PaymentMethod: String, Codable {
    case creditCard = "creditCard"
    case debitCard = "debitCard"
    case applePay = "applePay"
    case bankTransfer = "bankTransfer"
}

struct SavedPaymentMethod: Codable {
    var type: PaymentMethod
    var last4: String?
    var isDefault: Bool
    var cardBrand: String?
}

struct Payment: Codable {
    let id: String
    let bookingId: String
    let userId: String
    let providerId: String
    let amount: Double
    var status: PaymentStatus
    let paymentMethod: PaymentMethod
    let transactionId: String?
    let createdAt: Date
    var updatedAt: Date
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "bookingId": bookingId,
            "userId": userId,
            "providerId": providerId,
            "amount": amount,
            "status": status.rawValue,
            "paymentMethod": paymentMethod.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        
        if let transactionId = transactionId {
            dict["transactionId"] = transactionId
        }
        
        return dict
    }
    
    // Create from Firestore document
    static func fromDictionary(_ dict: [String: Any]) -> Payment? {
        guard let id = dict["id"] as? String,
              let bookingId = dict["bookingId"] as? String,
              let userId = dict["userId"] as? String,
              let providerId = dict["providerId"] as? String,
              let amount = dict["amount"] as? Double,
              let statusRaw = dict["status"] as? String,
              let status = PaymentStatus(rawValue: statusRaw),
              let paymentMethodRaw = dict["paymentMethod"] as? String,
              let paymentMethod = PaymentMethod(rawValue: paymentMethodRaw) else {
            return nil
        }
        
        // Handle dates
        let createdAt: Date
        if let timestamp = dict["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            return nil
        }
        
        let updatedAt: Date
        if let timestamp = dict["updatedAt"] as? Timestamp {
            updatedAt = timestamp.dateValue()
        } else {
            return nil
        }
        
        // Optional fields
        let transactionId = dict["transactionId"] as? String
        
        return Payment(
            id: id,
            bookingId: bookingId,
            userId: userId,
            providerId: providerId,
            amount: amount,
            status: status,
            paymentMethod: paymentMethod,
            transactionId: transactionId,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
import Foundation
import FirebaseFirestore
import UIKit

enum BookingStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayText: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending: return .systemYellow
        case .confirmed: return .systemBlue
        case .completed: return .systemGreen
        case .cancelled: return .systemRed
        }
    }
}

struct Booking {
    let id: String
    let serviceId: String
    let serviceName: String
    let providerId: String
    let providerName: String
    let clientId: String
    let clientName: String
    var status: BookingStatus
    let date: Date
    let price: Double
    var notes: String?
    let createdAt: Date
    var updatedAt: Date
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "serviceId": serviceId,
            "serviceName": serviceName,
            "providerId": providerId,
            "providerName": providerName,
            "clientId": clientId,
            "clientName": clientName,
            "status": status.rawValue,
            "date": Timestamp(date: date),
            "price": price,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        
        if let notes = notes {
            dict["notes"] = notes
        }
        
        return dict
    }
    
    // Create from Firestore document
    static func fromDictionary(_ dict: [String: Any]) -> Booking? {
        guard let id = dict["id"] as? String,
              let serviceId = dict["serviceId"] as? String,
              let serviceName = dict["serviceName"] as? String,
              let providerId = dict["providerId"] as? String,
              let providerName = dict["providerName"] as? String,
              let clientId = dict["clientId"] as? String,
              let clientName = dict["clientName"] as? String,
              let statusRaw = dict["status"] as? String,
              let status = BookingStatus(rawValue: statusRaw),
              let price = dict["price"] as? Double else {
            return nil
        }
        
        // Handle dates
        let date: Date
        if let timestamp = dict["date"] as? Timestamp {
            date = timestamp.dateValue()
        } else {
            return nil
        }
        
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
        let notes = dict["notes"] as? String
        
        return Booking(
            id: id,
            serviceId: serviceId,
            serviceName: serviceName,
            providerId: providerId,
            providerName: providerName,
            clientId: clientId,
            clientName: clientName,
            status: status,
            date: date,
            price: price,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
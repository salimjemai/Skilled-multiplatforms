import Foundation
import FirebaseFirestore

enum MessageType: String, Codable {
    case text
    case image
    case quoteRequest
    case quoteResponse
}

struct ChatMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let recipientId: String
    let content: String
    let timestamp: Date
    var isRead: Bool
    let messageType: MessageType
    
    // For quote-specific messages
    var quoteAmount: Double?
    var jobDescription: String?
    var estimatedDuration: Int?
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "senderId": senderId,
            "recipientId": recipientId,
            "content": content,
            "timestamp": Timestamp(date: timestamp),
            "isRead": isRead,
            "messageType": messageType.rawValue
        ]
        
        if let quoteAmount = quoteAmount {
            dict["quoteAmount"] = quoteAmount
        }
        
        if let jobDescription = jobDescription {
            dict["jobDescription"] = jobDescription
        }
        
        if let estimatedDuration = estimatedDuration {
            dict["estimatedDuration"] = estimatedDuration
        }
        
        return dict
    }
    
    // Create from Firestore document
    static func fromDictionary(_ dict: [String: Any]) -> ChatMessage? {
        guard let id = dict["id"] as? String,
              let senderId = dict["senderId"] as? String,
              let recipientId = dict["recipientId"] as? String,
              let content = dict["content"] as? String,
              let messageTypeString = dict["messageType"] as? String,
              let messageType = MessageType(rawValue: messageTypeString),
              let isRead = dict["isRead"] as? Bool else {
            return nil
        }
        
        // Handle timestamp
        let timestamp: Date
        if let timestampValue = dict["timestamp"] as? Timestamp {
            timestamp = timestampValue.dateValue()
        } else {
            timestamp = Date()
        }
        
        var message = ChatMessage(
            id: id,
            senderId: senderId,
            recipientId: recipientId,
            content: content,
            timestamp: timestamp,
            isRead: isRead,
            messageType: messageType
        )
        
        // Add optional fields
        message.quoteAmount = dict["quoteAmount"] as? Double
        message.jobDescription = dict["jobDescription"] as? String
        message.estimatedDuration = dict["estimatedDuration"] as? Int
        
        return message
    }
}

struct Conversation: Codable, Identifiable {
    let id: String
    let participants: [String] // User IDs
    var lastMessage: String
    var lastMessageTimestamp: Date
    var unreadCount: [String: Int] // User ID to unread count
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "participants": participants,
            "lastMessage": lastMessage,
            "lastMessageTimestamp": Timestamp(date: lastMessageTimestamp),
            "unreadCount": unreadCount
        ]
    }
    
    // Create from Firestore document
    static func fromDictionary(_ dict: [String: Any]) -> Conversation? {
        guard let id = dict["id"] as? String,
              let participants = dict["participants"] as? [String],
              let lastMessage = dict["lastMessage"] as? String,
              let unreadCount = dict["unreadCount"] as? [String: Int] else {
            return nil
        }
        
        // Handle timestamp
        let lastMessageTimestamp: Date
        if let timestampValue = dict["lastMessageTimestamp"] as? Timestamp {
            lastMessageTimestamp = timestampValue.dateValue()
        } else {
            lastMessageTimestamp = Date()
        }
        
        return Conversation(
            id: id,
            participants: participants,
            lastMessage: lastMessage,
            lastMessageTimestamp: lastMessageTimestamp,
            unreadCount: unreadCount
        )
    }
}
import Foundation
import FirebaseFirestore

class FirestoreSetupService {
    static let shared = FirestoreSetupService()
    private let db = Firestore.firestore()
    
    func setupCollections() {
        // Create conversations collection with a dummy document
        let conversationsRef = db.collection("conversations")
        conversationsRef.document("setup").setData([
            "id": "setup",
            "participants": [],
            "lastMessage": "",
            "lastMessageTimestamp": Timestamp(date: Date()),
            "unreadCount": [:]
        ])
        
        // Create messages collection with a dummy document
        let messagesRef = db.collection("messages")
        messagesRef.document("setup").setData([
            "id": "setup",
            "senderId": "",
            "recipientId": "",
            "content": "",
            "timestamp": Timestamp(date: Date()),
            "isRead": true,
            "messageType": "text"
        ])
        
        // Delete the setup documents after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            conversationsRef.document("setup").delete()
            messagesRef.document("setup").delete()
        }
    }
}
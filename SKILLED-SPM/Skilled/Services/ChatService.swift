import Foundation
import FirebaseFirestore
import FirebaseAuth

class ChatService {
    static let shared = ChatService()
    
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var conversationsListener: ListenerRegistration?
    
    // MARK: - Messages
    
    func sendMessage(to recipientId: String, content: String, messageType: MessageType = .text, 
                     quoteAmount: Double? = nil, jobDescription: String? = nil, 
                     estimatedDuration: Int? = nil, completion: @escaping (Error?) -> Void) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "ChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // Create a new message ID
        let messageId = db.collection("messages").document().documentID
        
        // Create the message
        var message = ChatMessage(
            id: messageId,
            senderId: currentUserId,
            recipientId: recipientId,
            content: content,
            timestamp: Date(),
            isRead: false,
            messageType: messageType
        )
        
        // Add quote-specific fields if needed
        message.quoteAmount = quoteAmount
        message.jobDescription = jobDescription
        message.estimatedDuration = estimatedDuration
        
        // Get the message dictionary and add participants array
        var messageData = message.toDictionary()
        messageData["participants"] = [currentUserId, recipientId]
        
        // Save the message to Firestore
        db.collection("messages").document(messageId).setData(messageData) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            print("Message sent successfully with ID: \(messageId)")
            
            // Update or create the conversation
            self.updateConversation(with: message) { error in
                completion(error)
            }
        }
    }
    
    func getMessages(with userId: String, completion: @escaping ([ChatMessage]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "ChatService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        // Remove any existing listener
        messagesListener?.remove()
        
        // Use a simpler query with the participants array
        messagesListener = db.collection("messages")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                // Filter messages for the specific conversation
                let messages = documents.compactMap { ChatMessage.fromDictionary($0.data()) }
                    .filter { ($0.senderId == currentUserId && $0.recipientId == userId) || 
                              ($0.senderId == userId && $0.recipientId == currentUserId) }
                
                print("Found \(messages.count) messages for conversation with \(userId)")
                completion(messages, nil)
                
                // Mark messages as read
                self.markMessagesAsRead(from: userId)
            }
    }
    
    private func markMessagesAsRead(from senderId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("messages")
            .whereField("senderId", isEqualTo: senderId)
            .whereField("recipientId", isEqualTo: currentUserId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, !documents.isEmpty else { return }
                
                let batch = self.db.batch()
                
                for document in documents {
                    batch.updateData(["isRead": true], forDocument: document.reference)
                }
                
                batch.commit()
            }
    }
    
    // MARK: - Conversations
    
    private func updateConversation(with message: ChatMessage, completion: @escaping (Error?) -> Void) {
        let conversationId = getConversationId(userId1: message.senderId, userId2: message.recipientId)
        
        // Check if conversation exists
        db.collection("conversations").document(conversationId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking conversation: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                // Update existing conversation
                print("Updating existing conversation: \(conversationId)")
                self.updateExistingConversation(conversationId: conversationId, message: message, completion: completion)
            } else {
                // Create new conversation
                print("Creating new conversation: \(conversationId)")
                self.createNewConversation(conversationId: conversationId, message: message, completion: completion)
            }
        }
    }
    
    private func updateExistingConversation(conversationId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        db.collection("conversations").document(conversationId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = snapshot?.data(),
                  var conversation = Conversation.fromDictionary(data) else {
                completion(NSError(domain: "ChatService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse conversation"]))
                return
            }
            
            // Update conversation
            conversation.lastMessage = message.content
            conversation.lastMessageTimestamp = message.timestamp
            
            // Increment unread count for recipient
            var unreadCount = conversation.unreadCount
            let currentCount = unreadCount[message.recipientId] ?? 0
            unreadCount[message.recipientId] = currentCount + 1
            conversation.unreadCount = unreadCount
            
            // Save updated conversation
            self.db.collection("conversations").document(conversationId).updateData(conversation.toDictionary()) { error in
                completion(error)
            }
        }
    }
    
    private func createNewConversation(conversationId: String, message: ChatMessage, completion: @escaping (Error?) -> Void) {
        let conversation = Conversation(
            id: conversationId,
            participants: [message.senderId, message.recipientId],
            lastMessage: message.content,
            lastMessageTimestamp: message.timestamp,
            unreadCount: [message.recipientId: 1, message.senderId: 0]
        )
        
        let conversationData = conversation.toDictionary()
        
        db.collection("conversations").document(conversationId).setData(conversationData) { error in
            if let error = error {
                print("Error creating conversation: \(error.localizedDescription)")
            } else {
                print("Successfully created conversation with ID: \(conversationId)")
            }
            completion(error)
        }
    }
    
    func getConversations(completion: @escaping ([Conversation]?, Error?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion([], nil) // Return empty array instead of error
            return
        }
        
        // Remove any existing listener
        conversationsListener?.remove()
        
        // Now we'll actually query for conversations
        conversationsListener = db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching conversations: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([], nil)
                    return
                }
                
                let conversations = documents.compactMap { Conversation.fromDictionary($0.data()) }
                print("Found \(conversations.count) conversations for user \(currentUserId)")
                completion(conversations, nil)
            }
    }
    
    // MARK: - Helper Methods
    
    private func getConversationId(userId1: String, userId2: String) -> String {
        // Create a consistent ID regardless of who is sender/recipient
        let sortedIds = [userId1, userId2].sorted()
        return sortedIds.joined(separator: "_")
    }
    
    func clearListeners() {
        messagesListener?.remove()
        conversationsListener?.remove()
    }
}
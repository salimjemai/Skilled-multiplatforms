import Foundation
import FirebaseFirestore
import FirebaseAuth

class PaymentService {
    private let db = Firestore.firestore()
    private let paymentsCollection = "payments"
    
    // Create a new payment
    func createPayment(for booking: Booking, method: PaymentMethod, completion: @escaping (Result<Payment, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "PaymentService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let paymentId = UUID().uuidString
        let now = Date()
        
        let payment = Payment(
            id: paymentId,
            bookingId: booking.id,
            userId: currentUser.uid,
            providerId: booking.providerId,
            amount: booking.price,
            status: .pending,
            paymentMethod: method,
            transactionId: nil,
            createdAt: now,
            updatedAt: now
        )
        
        db.collection(paymentsCollection).document(paymentId).setData(payment.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(payment))
        }
    }
    
    // Process payment (in a real app, this would integrate with a payment gateway)
    func processPayment(payment: Payment, completion: @escaping (Result<Payment, Error>) -> Void) {
        // Simulate payment processing
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // Update payment status to completed
            var updatedPayment = payment
            updatedPayment.status = .completed
            updatedPayment.updatedAt = Date()
            
            // Generate a mock transaction ID
            let mockTransactionId = "txn_\(UUID().uuidString.prefix(8))"
            
            // Update the payment in Firestore
            let updateData: [String: Any] = [
                "status": PaymentStatus.completed.rawValue,
                "updatedAt": Timestamp(date: Date()),
                "transactionId": mockTransactionId
            ]
            
            self.db.collection(self.paymentsCollection).document(payment.id).updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Return the updated payment
                completion(.success(updatedPayment))
            }
        }
    }
    
    // Get payment by ID
    func getPayment(id: String, completion: @escaping (Result<Payment, Error>) -> Void) {
        db.collection(paymentsCollection).document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let data = snapshot.data(),
                  let payment = Payment.fromDictionary(data) else {
                completion(.failure(NSError(domain: "PaymentService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Payment not found"])))
                return
            }
            
            completion(.success(payment))
        }
    }
    
    // Get payments for a user
    func getPaymentsForUser(userId: String, completion: @escaping (Result<[Payment], Error>) -> Void) {
        db.collection(paymentsCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let payments = documents.compactMap { Payment.fromDictionary($0.data()) }
                completion(.success(payments))
            }
    }
    
    // Get payments for a booking
    func getPaymentsForBooking(bookingId: String, completion: @escaping (Result<[Payment], Error>) -> Void) {
        db.collection(paymentsCollection)
            .whereField("bookingId", isEqualTo: bookingId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let payments = documents.compactMap { Payment.fromDictionary($0.data()) }
                completion(.success(payments))
            }
    }
    
    // Refund a payment
    func refundPayment(payment: Payment, completion: @escaping (Result<Payment, Error>) -> Void) {
        // In a real app, this would integrate with a payment gateway's refund API
        var updatedPayment = payment
        updatedPayment.status = .refunded
        updatedPayment.updatedAt = Date()
        
        let updateData: [String: Any] = [
            "status": PaymentStatus.refunded.rawValue,
            "updatedAt": Timestamp(date: Date())
        ]
        
        db.collection(paymentsCollection).document(payment.id).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(updatedPayment))
        }
    }
}
import Foundation
import UIKit

class PaymentManager {
    
    static let shared = PaymentManager()
    
    private init() {}
    
    // Store payment methods in UserDefaults
    private let paymentMethodsKey = "com.skilled.paymentMethods"
    
    // Save a payment method
    func savePaymentMethod(type: PaymentMethod, identifier: String?, token: String?) {
        var methods = getPaymentMethods()
        
        let newMethod: [String: Any] = [
            "type": type.rawValue,
            "identifier": identifier ?? "",
            "token": token ?? "",
            "dateAdded": Date().timeIntervalSince1970
        ]
        
        methods.append(newMethod)
        
        if let data = try? JSONSerialization.data(withJSONObject: methods) {
            UserDefaults.standard.set(data, forKey: paymentMethodsKey)
        }
        
        // Post notification that payment methods changed
        NotificationCenter.default.post(name: NSNotification.Name("PaymentMethodsChanged"), object: nil)
    }
    
    // Get all payment methods
    func getPaymentMethods() -> [[String: Any]] {
        guard let data = UserDefaults.standard.data(forKey: paymentMethodsKey),
              let methods = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return methods
    }
    
    // Delete a payment method
    func deletePaymentMethod(at index: Int) {
        var methods = getPaymentMethods()
        
        guard index < methods.count else { return }
        
        methods.remove(at: index)
        
        if let data = try? JSONSerialization.data(withJSONObject: methods) {
            UserDefaults.standard.set(data, forKey: paymentMethodsKey)
        }
        
        // Post notification that payment methods changed
        NotificationCenter.default.post(name: NSNotification.Name("PaymentMethodsChanged"), object: nil)
    }
    
    // Process a payment with a specific payment method
    func processPayment(amount: Double, methodIndex: Int, completion: @escaping (Bool, String?) -> Void) {
        let methods = getPaymentMethods()
        
        guard methodIndex < methods.count else {
            completion(false, "Invalid payment method")
            return
        }
        
        let method = methods[methodIndex]
        
        guard let typeString = method["type"] as? String,
              let type = PaymentMethod(rawValue: typeString) else {
            completion(false, "Invalid payment method type")
            return
        }
        
        // Simulate payment processing
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Generate a transaction ID
            let transactionId = "PMT-\(UUID().uuidString.prefix(8))"
            
            // Simulate success (95% of the time)
            let isSuccess = Double.random(in: 0...1) < 0.95
            
            DispatchQueue.main.async {
                if isSuccess {
                    completion(true, transactionId)
                } else {
                    completion(false, "Payment processing failed")
                }
            }
        }
    }
}
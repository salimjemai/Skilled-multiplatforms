import Foundation

// Extension to add persistence to PaymentMethodsViewController
extension PaymentMethodsViewController {
    
    // Save payment methods to UserDefaults
    func savePaymentMethods() {
        let data = try? JSONEncoder().encode(paymentMethods)
        UserDefaults.standard.set(data, forKey: "savedPaymentMethods")
    }
}
import Foundation
import PassKit

class PaymentValidationService {
    
    // Validate Apple Pay availability
    static func validateApplePay() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments()
    }
    
    // Validate PayPal account
    static func validatePayPal(email: String) -> Bool {
        // Check if the email format is valid
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Validate PayPal account with completion handler (for backward compatibility)
    static func validatePayPal(email: String, completion: @escaping (Bool) -> Void) {
        let isValid = validatePayPal(email: email)
        completion(isValid)
    }
    
    // Validate Google Pay account
    static func validateGooglePay(email: String, completion: @escaping (Bool) -> Void) {
        // Check if it's a Gmail address
        let isGmail = email.lowercased().hasSuffix("@gmail.com")
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(isGmail)
        }
    }
    
    // Validate credit card
    static func validateCreditCard(number: String) -> Bool {
        // Remove spaces and non-digits
        let cleanNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Check length (most cards are 13-19 digits)
        guard cleanNumber.count >= 13 && cleanNumber.count <= 19 else {
            return false
        }
        
        // Luhn algorithm validation
        var sum = 0
        let digits = cleanNumber.reversed().map { Int(String($0)) ?? 0 }
        
        for (index, digit) in digits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
}
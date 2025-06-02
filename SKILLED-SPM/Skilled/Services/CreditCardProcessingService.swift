import Foundation

class CreditCardProcessingService {
    
    // Process a credit card payment
    static func processPayment(cardNumber: String, expiryDate: String, cvv: String, amount: Double, completion: @escaping (Bool, String?) -> Void) {
        // In a real app, this would connect to a payment processor like Stripe
        // For this demo, we'll simulate a network request
        
        // First validate the card using Luhn algorithm
        let isValid = PaymentValidationService.validateCreditCard(number: cardNumber)
        
        if !isValid {
            completion(false, "Invalid card number")
            return
        }
        
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
            // Generate a mock transaction ID
            let transactionId = "TXN-\(UUID().uuidString.prefix(8))"
            
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
    
    // Get card type from number
    static func getCardType(from cardNumber: String) -> String {
        let cleanNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleanNumber.isEmpty {
            return "Unknown"
        }
        
        // Check first digit(s)
        let firstDigit = String(cleanNumber.prefix(1))
        let firstTwoDigits = cleanNumber.count >= 2 ? String(cleanNumber.prefix(2)) : ""
        
        switch firstDigit {
        case "4":
            return "Visa"
        case "5":
            if let prefix = Int(firstTwoDigits), (51...55).contains(prefix) {
                return "MasterCard"
            }
            return "Unknown"
        case "3":
            if firstTwoDigits == "34" || firstTwoDigits == "37" {
                return "American Express"
            }
            return "Unknown"
        case "6":
            return "Discover"
        default:
            return "Unknown"
        }
    }
    
    // Format card number with spaces
    static func formatCardNumber(_ cardNumber: String) -> String {
        let cleanNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        
        for (index, character) in cleanNumber.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result += String(character)
        }
        
        return result
    }
    
    // Get masked card number (e.g., **** **** **** 1234)
    static func getMaskedCardNumber(_ cardNumber: String) -> String {
        let cleanNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleanNumber.count < 4 {
            return cleanNumber
        }
        
        let last4 = String(cleanNumber.suffix(4))
        return "**** **** **** \(last4)"
    }
}
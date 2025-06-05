import UIKit

class CardBrandManager {
    
    static let shared = CardBrandManager()
    
    // Card brand images stored in memory
    private var brandImages: [String: UIImage] = [:]
    
    private init() {
        // Initialize with system images
        setupDefaultImages()
    }
    
    private func setupDefaultImages() {
        // Credit cards
        brandImages["visa"] = createVisaImage()
        brandImages["mastercard"] = createMastercardImage()
        brandImages["amex"] = createAmexImage()
        brandImages["discover"] = createDiscoverImage()
        brandImages["jcb"] = UIImage(systemName: "creditcard")
        brandImages["diners"] = UIImage(systemName: "creditcard")
        brandImages["unionpay"] = UIImage(systemName: "creditcard")
        
        // Digital wallets
        brandImages["applepay"] = UIImage(systemName: "applepay")
        brandImages["paypal"] = createPayPalImage()
        brandImages["googlepay"] = createGooglePayImage()
        
        // Generic
        brandImages["generic"] = UIImage(systemName: "creditcard")
    }
    
    // Detect card brand from number
    func detectBrand(from cardNumber: String) -> String {
        let cleanNumber = cardNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if cleanNumber.isEmpty {
            return "generic"
        }
        
        // Check first digits
        if cleanNumber.hasPrefix("4") {
            return "visa"
        } else if let prefix = Int(cleanNumber.prefix(2)), (51...55).contains(prefix) {
            return "mastercard"
        } else if cleanNumber.hasPrefix("34") || cleanNumber.hasPrefix("37") {
            return "amex"
        } else if cleanNumber.hasPrefix("6") {
            return "discover"
        } else if cleanNumber.hasPrefix("35") {
            return "jcb"
        } else if cleanNumber.hasPrefix("30") || cleanNumber.hasPrefix("36") || cleanNumber.hasPrefix("38") {
            return "diners"
        } else if cleanNumber.hasPrefix("62") {
            return "unionpay"
        }
        
        return "generic"
    }
    
    // Get image for card brand - only one method to avoid ambiguity
    func getImage(for brand: String) -> UIImage {
        return brandImages[brand.lowercased()] ?? brandImages["generic"]!
    }
    
    // MARK: - Image Creation Methods
    
    private func createVisaImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // Blue rectangle
            UIColor(red: 0, green: 0.4, blue: 0.8, alpha: 1.0).setFill()
            let bluePath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 12), cornerRadius: 0)
            bluePath.fill()
            
            // Gold rectangle
            UIColor(red: 0.8, green: 0.7, blue: 0.1, alpha: 1.0).setFill()
            let goldPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 26, width: 56, height: 12), cornerRadius: 0)
            goldPath.fill()
            
            // VISA text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let text = "VISA"
            let textRect = CGRect(x: 2, y: 10, width: 56, height: 20)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func createMastercardImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // Red circle
            UIColor.systemRed.setFill()
            let redCirclePath = UIBezierPath(ovalIn: CGRect(x: 30, y: 10, width: 20, height: 20))
            redCirclePath.fill()
            
            // Yellow circle
            UIColor.systemYellow.setFill()
            let yellowCirclePath = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: 20, height: 20))
            yellowCirclePath.fill()
            
            // Overlap with orange
            UIColor.systemOrange.setFill()
            let overlapPath = UIBezierPath()
            overlapPath.move(to: CGPoint(x: 30, y: 20))
            overlapPath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 10, startAngle: 0, endAngle: .pi, clockwise: true)
            overlapPath.addArc(withCenter: CGPoint(x: 40, y: 20), radius: 10, startAngle: .pi, endAngle: 0, clockwise: true)
            overlapPath.close()
            overlapPath.fill()
        }
    }
    
    private func createAmexImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background - Amex Blue
            UIColor(red: 0.1, green: 0.4, blue: 0.7, alpha: 1.0).setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let text = "AMEX"
            let textRect = CGRect(x: 2, y: 15, width: 56, height: 20)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func createDiscoverImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // Orange arc
            UIColor.systemOrange.setFill()
            let arcPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 22, width: 56, height: 16), cornerRadius: 0)
            arcPath.fill()
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let text = "Discover"
            let textRect = CGRect(x: 2, y: 8, width: 56, height: 20)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func createPayPalImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // PayPal colors
            let darkBlue = UIColor(red: 0.0, green: 0.15, blue: 0.4, alpha: 1.0)
            let lightBlue = UIColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 1.0)
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributesDark: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: darkBlue,
                .paragraphStyle: paragraphStyle
            ]
            
            let attributesLight: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: lightBlue,
                .paragraphStyle: paragraphStyle
            ]
            
            "Pay".draw(in: CGRect(x: 10, y: 10, width: 30, height: 20), withAttributes: attributesDark)
            "Pal".draw(in: CGRect(x: 30, y: 10, width: 30, height: 20), withAttributes: attributesLight)
        }
    }
    
    private func createGooglePayImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 40))
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            let backgroundPath = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 56, height: 36), cornerRadius: 4)
            backgroundPath.fill()
            
            // Google colors
            let blue = UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1.0)
            let red = UIColor(red: 0.86, green: 0.27, blue: 0.22, alpha: 1.0)
            let yellow = UIColor(red: 0.98, green: 0.73, blue: 0.01, alpha: 1.0)
            let green = UIColor(red: 0.13, green: 0.59, blue: 0.25, alpha: 1.0)
            
            // Draw G
            let gPath = UIBezierPath()
            gPath.move(to: CGPoint(x: 15, y: 20))
            gPath.addArc(withCenter: CGPoint(x: 15, y: 20), radius: 8, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            blue.setStroke()
            gPath.lineWidth = 2
            gPath.stroke()
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            "G Pay".draw(in: CGRect(x: 25, y: 15, width: 30, height: 20), withAttributes: attributes)
        }
    }
}
import UIKit

class PaymentMethodCardView: UIView {
    
    // MARK: - UI Components
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expiryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    private var cardBrand: String = "generic"
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Card background
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        // Default gradient background
        setGradientBackground(startColor: .systemBlue, endColor: .systemIndigo)
        
        // Add components
        addSubview(cardImageView)
        addSubview(cardNumberLabel)
        addSubview(cardholderLabel)
        addSubview(expiryLabel)
        
        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cardImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardImageView.widthAnchor.constraint(equalToConstant: 60),
            cardImageView.heightAnchor.constraint(equalToConstant: 40),
            
            cardNumberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardNumberLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            cardholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            cardholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            expiryLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            expiryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        // Set default values
        cardNumberLabel.text = "•••• •••• •••• ••••"
        cardholderLabel.text = "CARD HOLDER"
        expiryLabel.text = "MM/YY"
        cardImageView.image = CardBrandManager.shared.getImage(for: "generic")
    }
    
    // MARK: - Configuration
    func configure(with paymentMethod: (type: PaymentMethod, last4: String?)) {
        switch paymentMethod.type {
        case .creditCard:
            if let last4 = paymentMethod.last4 {
                cardNumberLabel.text = "•••• •••• •••• \(last4)"
                
                // Determine card brand based on first digit
                if last4.hasPrefix("4") {
                    cardBrand = "visa"
                    setGradientBackground(startColor: .systemBlue, endColor: .systemIndigo)
                } else if last4.hasPrefix("5") {
                    cardBrand = "mastercard"
                    setGradientBackground(startColor: .systemRed, endColor: .systemOrange)
                } else if last4.hasPrefix("3") {
                    cardBrand = "amex"
                    setGradientBackground(startColor: .systemTeal, endColor: .systemBlue)
                } else if last4.hasPrefix("6") {
                    cardBrand = "discover"
                    setGradientBackground(startColor: .systemOrange, endColor: .systemYellow)
                } else {
                    cardBrand = "generic"
                    setGradientBackground(startColor: .darkGray, endColor: .black)
                }
            } else {
                cardBrand = "generic"
                setGradientBackground(startColor: .darkGray, endColor: .black)
            }
            
        case .debitCard:
            if let last4 = paymentMethod.last4 {
                if last4 == "Google Pay" {
                    cardBrand = "googlepay"
                    cardNumberLabel.text = "Google Pay"
                    setGradientBackground(startColor: .systemBlue, endColor: .systemGreen)
                } else {
                    cardBrand = "discover"
                    cardNumberLabel.text = "•••• •••• •••• \(last4)"
                    setGradientBackground(startColor: .systemOrange, endColor: .systemYellow)
                }
            } else {
                cardBrand = "generic"
                setGradientBackground(startColor: .darkGray, endColor: .black)
            }
            
        case .applePay:
            cardBrand = "applepay"
            cardNumberLabel.text = "Apple Pay"
            setGradientBackground(startColor: .black, endColor: .darkGray)
            
        case .bankTransfer:
            if let last4 = paymentMethod.last4, last4 == "PayPal" {
                cardBrand = "paypal"
                cardNumberLabel.text = "PayPal"
                setGradientBackground(startColor: .systemBlue, endColor: .systemIndigo)
            } else {
                cardBrand = "generic"
                cardNumberLabel.text = "Bank Transfer"
                setGradientBackground(startColor: .systemGreen, endColor: .systemTeal)
            }
        }
        
        // Update card image
        cardImageView.image = CardBrandManager.shared.getImage(for: cardBrand)
    }
    
    // MARK: - Helper Methods
    private func setGradientBackground(startColor: UIColor, endColor: UIColor) {
        // Remove existing gradient layers
        layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Create new gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = bounds
        
        // Insert at index 0 to be behind all other views
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame when view size changes
        layer.sublayers?.forEach { layer in
            if let gradientLayer = layer as? CAGradientLayer {
                gradientLayer.frame = bounds
            }
        }
    }
}
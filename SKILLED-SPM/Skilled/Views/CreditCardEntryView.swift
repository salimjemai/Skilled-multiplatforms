import UIKit

class CreditCardEntryView: UIView {
    
    // MARK: - UI Components
    private let cardNumberField: UITextField = {
        let field = UITextField()
        field.placeholder = "Card Number"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "creditcard")
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let expiryDateField: UITextField = {
        let field = UITextField()
        field.placeholder = "MM/YY"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let cvvField: UITextField = {
        let field = UITextField()
        field.placeholder = "CVV"
        field.keyboardType = .numberPad
        field.isSecureTextEntry = true
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let nameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Cardholder Name"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .words
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let cardFrontView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "•••• •••• •••• ••••"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardholderLabel: UILabel = {
        let label = UILabel()
        label.text = "CARDHOLDER NAME"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expiryLabel: UILabel = {
        let label = UILabel()
        label.text = "MM/YY"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Add card visual representation
        addSubview(cardFrontView)
        cardFrontView.addSubview(cardImageView)
        cardFrontView.addSubview(cardNumberLabel)
        cardFrontView.addSubview(cardholderLabel)
        cardFrontView.addSubview(expiryLabel)
        
        // Add input fields
        addSubview(cardNumberField)
        addSubview(expiryDateField)
        addSubview(cvvField)
        addSubview(nameField)
        
        NSLayoutConstraint.activate([
            cardFrontView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cardFrontView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardFrontView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardFrontView.heightAnchor.constraint(equalToConstant: 180),
            
            cardImageView.topAnchor.constraint(equalTo: cardFrontView.topAnchor, constant: 15),
            cardImageView.trailingAnchor.constraint(equalTo: cardFrontView.trailingAnchor, constant: -15),
            cardImageView.widthAnchor.constraint(equalToConstant: 40),
            cardImageView.heightAnchor.constraint(equalToConstant: 30),
            
            cardNumberLabel.centerYAnchor.constraint(equalTo: cardFrontView.centerYAnchor),
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardFrontView.leadingAnchor, constant: 20),
            cardNumberLabel.trailingAnchor.constraint(equalTo: cardFrontView.trailingAnchor, constant: -20),
            
            cardholderLabel.bottomAnchor.constraint(equalTo: cardFrontView.bottomAnchor, constant: -20),
            cardholderLabel.leadingAnchor.constraint(equalTo: cardFrontView.leadingAnchor, constant: 20),
            cardholderLabel.widthAnchor.constraint(equalTo: cardFrontView.widthAnchor, multiplier: 0.7),
            
            expiryLabel.bottomAnchor.constraint(equalTo: cardFrontView.bottomAnchor, constant: -20),
            expiryLabel.trailingAnchor.constraint(equalTo: cardFrontView.trailingAnchor, constant: -20),
            
            cardNumberField.topAnchor.constraint(equalTo: cardFrontView.bottomAnchor, constant: 30),
            cardNumberField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardNumberField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardNumberField.heightAnchor.constraint(equalToConstant: 44),
            
            nameField.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 15),
            nameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameField.heightAnchor.constraint(equalToConstant: 44),
            
            expiryDateField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 15),
            expiryDateField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            expiryDateField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45, constant: -25),
            expiryDateField.heightAnchor.constraint(equalToConstant: 44),
            
            cvvField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 15),
            cvvField.leadingAnchor.constraint(equalTo: expiryDateField.trailingAnchor, constant: 10),
            cvvField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cvvField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        cardNumberField.addTarget(self, action: #selector(cardNumberChanged), for: .editingChanged)
        nameField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        expiryDateField.addTarget(self, action: #selector(expiryChanged), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc private func cardNumberChanged() {
        if let text = cardNumberField.text {
            // Format card number with spaces
            let formattedNumber = formatCardNumber(text)
            if formattedNumber != text {
                cardNumberField.text = formattedNumber
            }
            
            // Update card number display
            if text.isEmpty {
                cardNumberLabel.text = "•••• •••• •••• ••••"
            } else {
                cardNumberLabel.text = formattedNumber
            }
            
            // Update card type image
            updateCardTypeImage(for: text)
        }
    }
    
    @objc private func nameChanged() {
        if let text = nameField.text, !text.isEmpty {
            cardholderLabel.text = text.uppercased()
        } else {
            cardholderLabel.text = "CARDHOLDER NAME"
        }
    }
    
    @objc private func expiryChanged() {
        if let text = expiryDateField.text {
            // Format expiry date with slash
            let formattedDate = formatExpiryDate(text)
            if formattedDate != text {
                expiryDateField.text = formattedDate
            }
            
            // Update expiry date display
            if text.isEmpty {
                expiryLabel.text = "MM/YY"
            } else {
                expiryLabel.text = formattedDate
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatCardNumber(_ text: String) -> String {
        let numbers = text.replacingOccurrences(of: " ", with: "")
        var result = ""
        for (index, character) in numbers.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result += String(character)
        }
        return result
    }
    
    private func formatExpiryDate(_ text: String) -> String {
        let numbers = text.replacingOccurrences(of: "/", with: "")
        var result = ""
        for (index, character) in numbers.enumerated() {
            if index == 2 {
                result += "/"
            }
            result += String(character)
        }
        return result
    }
    
    private func updateCardTypeImage(for cardNumber: String) {
        let cleanNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        
        if cleanNumber.isEmpty {
            cardImageView.image = UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemGray
            return
        }
        
        if cleanNumber.hasPrefix("4") {
            // Visa
            cardImageView.image = UIImage(named: "visa") ?? UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemBlue
        } else if cleanNumber.hasPrefix("5") {
            // MasterCard
            cardImageView.image = UIImage(named: "mastercard") ?? UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemRed
        } else if cleanNumber.hasPrefix("3") {
            // Amex
            cardImageView.image = UIImage(named: "amex") ?? UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemIndigo
        } else if cleanNumber.hasPrefix("6") {
            // Discover
            cardImageView.image = UIImage(named: "discover") ?? UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemOrange
        } else {
            cardImageView.image = UIImage(systemName: "creditcard")
            cardImageView.tintColor = .systemGray
        }
    }
    
    // MARK: - Public Methods
    func getCardDetails() -> (cardNumber: String, expiryDate: String, cvv: String, name: String)? {
        guard let cardNumber = cardNumberField.text, !cardNumber.isEmpty,
              let expiryDate = expiryDateField.text, !expiryDate.isEmpty,
              let cvv = cvvField.text, !cvv.isEmpty,
              let name = nameField.text, !name.isEmpty else {
            return nil
        }
        
        return (
            cardNumber: cardNumber.replacingOccurrences(of: " ", with: ""),
            expiryDate: expiryDate,
            cvv: cvv,
            name: name
        )
    }
}
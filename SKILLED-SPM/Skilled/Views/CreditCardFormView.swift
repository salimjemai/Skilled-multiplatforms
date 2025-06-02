import UIKit

protocol CreditCardFormViewDelegate: AnyObject {
    func didSubmitCardDetails(cardNumber: String, expiryDate: String, cvv: String, cardholderName: String)
}

class CreditCardFormView: UIView {
    
    // MARK: - UI Components
    private let cardNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Card Number"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let expiryDateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "MM/YY"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let cvvTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "CVV"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let cardholderNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Cardholder Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Card", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: CreditCardFormViewDelegate?
    
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
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(cardNumberTextField)
        addSubview(expiryDateTextField)
        addSubview(cvvTextField)
        addSubview(cardholderNameTextField)
        addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            cardNumberTextField.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            cardNumberTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardNumberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: 44),
            
            expiryDateTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 15),
            expiryDateTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            expiryDateTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45, constant: -25),
            expiryDateTextField.heightAnchor.constraint(equalToConstant: 44),
            
            cvvTextField.topAnchor.constraint(equalTo: cardNumberTextField.bottomAnchor, constant: 15),
            cvvTextField.leadingAnchor.constraint(equalTo: expiryDateTextField.trailingAnchor, constant: 10),
            cvvTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cvvTextField.heightAnchor.constraint(equalToConstant: 44),
            
            cardholderNameTextField.topAnchor.constraint(equalTo: expiryDateTextField.bottomAnchor, constant: 15),
            cardholderNameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardholderNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardholderNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            submitButton.topAnchor.constraint(equalTo: cardholderNameTextField.bottomAnchor, constant: 25),
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
        
        // Set delegates for text formatting
        cardNumberTextField.delegate = self
        expiryDateTextField.delegate = self
        cvvTextField.delegate = self
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc private func submitButtonTapped() {
        guard let cardNumber = cardNumberTextField.text, !cardNumber.isEmpty,
              let expiryDate = expiryDateTextField.text, !expiryDate.isEmpty,
              let cvv = cvvTextField.text, !cvv.isEmpty,
              let cardholderName = cardholderNameTextField.text, !cardholderName.isEmpty else {
            // Show validation error
            return
        }
        
        // Notify delegate
        delegate?.didSubmitCardDetails(
            cardNumber: cardNumber.replacingOccurrences(of: " ", with: ""),
            expiryDate: expiryDate,
            cvv: cvv,
            cardholderName: cardholderName
        )
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
}

// MARK: - UITextFieldDelegate
extension CreditCardFormView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case cardNumberTextField:
            // Limit to 19 characters (16 digits + 3 spaces)
            if newText.count > 19 { return false }
            
            // Only allow digits
            if !string.isEmpty && !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return false
            }
            
            // Format card number with spaces
            let formattedText = formatCardNumber(newText)
            if formattedText != newText {
                textField.text = formattedText
                return false
            }
            
        case expiryDateTextField:
            // Limit to 5 characters (MM/YY)
            if newText.count > 5 { return false }
            
            // Only allow digits
            if !string.isEmpty && !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                return false
            }
            
            // Format expiry date with slash
            if newText.count == 2 && text.count == 1 {
                textField.text = newText + "/"
                return false
            }
            
        case cvvTextField:
            // Limit to 3-4 digits
            if newText.count > 4 { return false }
            
            // Only allow digits
            return string.isEmpty || CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
            
        default:
            return true
        }
        
        return true
    }
}
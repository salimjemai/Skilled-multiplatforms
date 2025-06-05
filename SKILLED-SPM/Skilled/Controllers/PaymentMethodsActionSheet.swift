import UIKit

class PaymentMethodsActionSheet: UIViewController {
    
    weak var delegate: PaymentMethodsActionSheetDelegate?
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20)
        ])
        
        // Credit Card Button
        let cardButton = createPaymentButton(
            title: "Credit/Debit Card",
            image: UIImage(named: "visa") ?? UIImage(systemName: "creditcard.fill"),
            action: #selector(creditCardTapped)
        )
        
        // Apple Pay Button
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let applePayIconName = isDarkMode ? "applepay-dark" : "applepay-light"
        let applePayButton = createPaymentButton(
            title: "Apple Pay",
            image: UIImage(named: applePayIconName) ?? UIImage(systemName: "applepay"),
            action: #selector(applePayTapped)
        )
        
        // PayPal Button
        let payPalButton = createPaymentButton(
            title: "PayPal",
            image: UIImage(named: "paypal") ?? UIImage(systemName: "p.circle.fill"),
            action: #selector(payPalTapped)
        )
        
        // Google Pay Button
        let googlePayButton = createPaymentButton(
            title: "Google Pay",
            image: UIImage(named: "google-pay") ?? UIImage(systemName: "g.circle.fill"),
            action: #selector(googlePayTapped)
        )
        
        // Cancel Button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        stackView.addArrangedSubview(cardButton)
        stackView.addArrangedSubview(applePayButton)
        stackView.addArrangedSubview(payPalButton)
        stackView.addArrangedSubview(googlePayButton)
        stackView.addArrangedSubview(cancelButton)
    }
    
    private func createPaymentButton(title: String, image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        if let image = image {
            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    @objc private func creditCardTapped() {
        dismiss(animated: true) {
            self.delegate?.addCardPaymentMethod()
        }
    }
    
    @objc private func applePayTapped() {
        dismiss(animated: true) {
            self.delegate?.setupApplePay()
        }
    }
    
    @objc private func payPalTapped() {
        dismiss(animated: true) {
            self.delegate?.setupPayPal()
        }
    }
    
    @objc private func googlePayTapped() {
        dismiss(animated: true) {
            self.delegate?.setupGooglePay()
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}
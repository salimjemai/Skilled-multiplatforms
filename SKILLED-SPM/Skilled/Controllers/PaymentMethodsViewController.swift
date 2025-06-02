import UIKit
import PassKit
import StoreKit

class PaymentMethodsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PaymentMethodCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let addPaymentMethodButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Payment Method", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var paymentMethods: [(type: PaymentMethod, last4: String?)] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment Methods"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        loadPaymentMethods()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(addPaymentMethodButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addPaymentMethodButton.topAnchor, constant: -20),
            
            addPaymentMethodButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addPaymentMethodButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addPaymentMethodButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addPaymentMethodButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupActions() {
        addPaymentMethodButton.addTarget(self, action: #selector(addPaymentMethodTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadPaymentMethods() {
        // In a real app, this would load from a database or API
        // For this example, we'll use mock data
        paymentMethods = [
            (.creditCard, "4242"),
            (.debitCard, "5678"),
            (.applePay, nil)
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addPaymentMethodTapped() {
        let actionSheet = UIAlertController(title: "Add Payment Method", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Credit/Debit Card", style: .default) { [weak self] _ in
            self?.addCardPaymentMethod()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Apple Pay", style: .default) { [weak self] _ in
            self?.setupApplePay()
        })
        
        actionSheet.addAction(UIAlertAction(title: "PayPal", style: .default) { [weak self] _ in
            self?.setupPayPal()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Google Pay", style: .default) { [weak self] _ in
            self?.setupGooglePay()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = addPaymentMethodButton
            popoverController.sourceRect = addPaymentMethodButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    private lazy var payPalHandler = PayPalHandler(viewController: self)
    
    private func setupPayPal() {
        // Show PayPal setup UI with email input
        let alert = UIAlertController(
            title: "Connect PayPal",
            message: "Enter your PayPal email address to connect your account.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "PayPal Email"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Connect", style: .default) { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text, !email.isEmpty else {
                // Show error for empty email
                self?.showValidationError(message: "Please enter your PayPal email address.")
                return
            }
            
            // Validate email format
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            let isValidEmail = emailPredicate.evaluate(with: email)
            
            if isValidEmail {
                // Launch PayPal authentication web view
                let authVC = PaymentAuthWebViewController(paymentType: "PayPal", email: email)
                let navController = UINavigationController(rootViewController: authVC)
                authVC.delegate = self
                
                self?.present(navController, animated: true)
            } else {
                self?.showValidationError(message: "Invalid PayPal email address. Please check and try again.")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showValidationError(message: String) {
        let alert = UIAlertController(
            title: "Validation Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private func showLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        view.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
    
    private lazy var googlePayHandler = GooglePayHandler(viewController: self)
    
    private func setupGooglePay() {
        // Show Google Pay setup UI with email input
        let alert = UIAlertController(
            title: "Connect Google Pay",
            message: "Enter your Gmail address to connect your Google Pay account.",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Gmail Address"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
        }
        
        alert.addAction(UIAlertAction(title: "Connect", style: .default) { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text, !email.isEmpty else {
                // Show error for empty email
                self?.showValidationError(message: "Please enter your Gmail address.")
                return
            }
            
            // Validate Gmail format
            let isGmail = email.lowercased().hasSuffix("@gmail.com")
            
            if isGmail {
                // Launch Google Pay authentication web view
                let authVC = PaymentAuthWebViewController(paymentType: "Google Pay", email: email)
                let navController = UINavigationController(rootViewController: authVC)
                authVC.delegate = self
                
                self?.present(navController, animated: true)
            } else {
                // Show validation error
                self?.showValidationError(message: "Please use a valid Gmail address for Google Pay.")
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addCardPaymentMethod() {
        // Create a view controller for the credit card entry
        let cardVC = UIViewController()
        cardVC.title = "Add Credit Card"
        
        // Create the credit card entry view
        let cardEntryView = CreditCardEntryView(frame: .zero)
        cardEntryView.translatesAutoresizingMaskIntoConstraints = false
        cardVC.view.addSubview(cardEntryView)
        
        // Add a submit button
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Add Card", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        cardVC.view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            cardEntryView.topAnchor.constraint(equalTo: cardVC.view.safeAreaLayoutGuide.topAnchor),
            cardEntryView.leadingAnchor.constraint(equalTo: cardVC.view.leadingAnchor),
            cardEntryView.trailingAnchor.constraint(equalTo: cardVC.view.trailingAnchor),
            cardEntryView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: cardVC.view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: cardVC.view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: cardVC.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add action to submit button
        submitButton.addAction(UIAction { [weak self, weak cardEntryView] _ in
            guard let cardDetails = cardEntryView?.getCardDetails() else {
                self?.showValidationError(message: "Please fill in all card details")
                return
            }
            
            // Process the card
            self?.processCardPayment(
                cardNumber: cardDetails.cardNumber,
                expiryDate: cardDetails.expiryDate,
                cvv: cardDetails.cvv,
                cardholderName: cardDetails.name
            )
            
            // Dismiss the card entry view
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        // Present the card entry view controller
        let navController = UINavigationController(rootViewController: cardVC)
        present(navController, animated: true)
    }
    
    private func processCardPayment(cardNumber: String, expiryDate: String, cvv: String, cardholderName: String) {
        // Show loading indicator
        showLoadingIndicator()
        
        // Process the credit card payment (with $0.01 test amount)
        CreditCardProcessingService.processPayment(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            amount: 0.01
        ) { [weak self] success, transactionId in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                
                if success {
                    // Get last 4 digits of card number
                    let last4 = String(cardNumber.suffix(4))
                    
                    // Get card type
                    let cardTypeName = CreditCardProcessingService.getCardType(from: cardNumber)
                    let cardType: PaymentMethod = cardTypeName == "Discover" ? .debitCard : .creditCard
                    
                    // Add the new card to the payment methods
                    self?.paymentMethods.append((cardType, last4))
                    self?.tableView.reloadData()
                    
                    // Show success message
                    let alert = UIAlertController(
                        title: "Card Added",
                        message: "Your \(cardTypeName) card ending in \(last4) has been added successfully.\nTransaction ID: \(transactionId ?? "Unknown")",
                        preferredStyle: .alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    // Show validation error
                    self?.showValidationError(message: "Card processing failed: \(transactionId ?? "Unknown error"). Please try again.")
                }
            }
        }
    }
    
    private lazy var applePayHandler = ApplePayHandler(viewController: self)
    
    private func setupApplePay() {
        // Validate Apple Pay availability
        if PKPaymentAuthorizationViewController.canMakePayments() {
            // Check if specific payment networks are available
            let availableNetworks = [PKPaymentNetwork.visa, .masterCard, .amex]
            let canMakePaymentsWithNetworks = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: availableNetworks)
            
            if canMakePaymentsWithNetworks {
                // For Apple Pay, we can either:
                // 1. Use the native Apple Pay sheet (better UX)
                // 2. Use a web view for consistency with other payment methods
                
                // Option 1: Native Apple Pay (recommended)
                let request = PKPaymentRequest()
                request.merchantIdentifier = "merchant.com.skilled.payments"
                request.supportedNetworks = availableNetworks
                request.merchantCapabilities = .capability3DS
                request.countryCode = "US"
                request.currencyCode = "USD"
                
                // Add a small verification amount
                let paymentItem = PKPaymentSummaryItem(label: "Verify Account", amount: NSDecimalNumber(value: 0.01))
                request.paymentSummaryItems = [paymentItem]
                
                if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
                    paymentVC.delegate = self
                    present(paymentVC, animated: true)
                }
                
                // Option 2: Web authentication (alternative)
                // let authVC = PaymentAuthWebViewController(paymentType: "Apple Pay")
                // let navController = UINavigationController(rootViewController: authVC)
                // authVC.delegate = self
                // present(navController, animated: true)
            } else {
                // Show setup message
                let alert = UIAlertController(
                    title: "Apple Pay Setup Required",
                    message: "Apple Pay is available on your device, but you need to add a payment card in Wallet first.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Open Wallet", style: .default) { _ in
                    // Open Wallet app
                    if let walletURL = URL(string: "shoebox://") {
                        UIApplication.shared.open(walletURL)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                present(alert, animated: true)
            }
        } else {
            // Show error message
            let alert = UIAlertController(
                title: "Apple Pay Not Available",
                message: "Your device does not support Apple Pay or it is not set up properly.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func deletePaymentMethod(at index: Int) {
        // In a real app, this would delete from a database or API
        paymentMethods.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// MARK: - PaymentAuthWebViewControllerDelegate
extension PaymentMethodsViewController: PaymentAuthWebViewControllerDelegate {
    func didCompleteAuthentication(success: Bool, token: String?) {
        if success, let token = token {
            // Determine which payment method was added based on the most recent action
            if token.hasPrefix("AUTH-") {
                // Add the payment method
                if token.contains("PayPal") {
                    paymentMethods.append((.bankTransfer, "PayPal"))
                } else if token.contains("Google") {
                    paymentMethods.append((.debitCard, "Google Pay"))
                }
                
                tableView.reloadData()
                
                // Show success message
                let alert = UIAlertController(
                    title: "Payment Method Added",
                    message: "Your payment method has been successfully connected.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        } else {
            showValidationError(message: "Authentication failed. Please try again.")
        }
    }
    
    func didCancelAuthentication() {
        // User canceled the authentication process
    }
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate
extension PaymentMethodsViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // In a real app, you would send the payment token to your server
        // For this demo, we'll simulate a successful payment
        
        // Add Apple Pay as a payment method
        DispatchQueue.main.async { [weak self] in
            self?.paymentMethods.append((.applePay, nil))
            self?.tableView.reloadData()
        }
        
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension PaymentMethodsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell", for: indexPath)
        let paymentMethod = paymentMethods[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        switch paymentMethod.type {
        case .creditCard:
            content.text = "Credit Card"
            content.image = UIImage(systemName: "creditcard")
            if let last4 = paymentMethod.last4 {
                content.secondaryText = "•••• \(last4)"
            }
        case .debitCard:
            content.text = "Debit Card"
            content.image = UIImage(systemName: "creditcard")
            if let last4 = paymentMethod.last4 {
                content.secondaryText = "•••• \(last4)"
            }
        case .applePay:
            content.text = "Apple Pay"
            content.image = UIImage(systemName: "applepay")
        case .bankTransfer:
            content.text = "Bank Transfer"
            content.image = UIImage(systemName: "building.columns")
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Saved Payment Methods"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePaymentMethod(at: indexPath.row)
        }
    }
}
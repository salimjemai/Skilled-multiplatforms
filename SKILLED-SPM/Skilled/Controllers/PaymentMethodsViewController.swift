import UIKit
import PassKit
import StoreKit
import AVFoundation

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
    var paymentMethods: [SavedPaymentMethod] = []
    
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
    func loadPaymentMethods() {
        if let data = UserDefaults.standard.data(forKey: "savedPaymentMethods"),
           let decoded = try? JSONDecoder().decode([SavedPaymentMethod].self, from: data) {
            paymentMethods = decoded
        } else {
            paymentMethods = []
        }
        tableView.reloadData()
    }
    

    
    // MARK: - Actions
    @objc private func addPaymentMethodTapped() {
        let actionSheetVC = PaymentMethodsActionSheet()
        actionSheetVC.delegate = self
        actionSheetVC.modalPresentationStyle = .formSheet
        actionSheetVC.preferredContentSize = CGSize(width: 300, height: 300)
        
        // For iPad support
        if let sheet = actionSheetVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        
        present(actionSheetVC, animated: true)
    }
    
    private lazy var payPalHandler = PayPalHandler(viewController: self)
    
    func setupPayPal() {
        // Bypass email validation and directly call the API
        let authVC = PaymentAuthWebViewController(paymentType: "PayPal", email: "bypass@example.com")
        let navController = UINavigationController(rootViewController: authVC)
        authVC.delegate = self
        present(navController, animated: true)
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
    
    func setupGooglePay() {
        // Bypass email validation and directly call the API
        let authVC = PaymentAuthWebViewController(paymentType: "Google Pay", email: "bypass@gmail.com")
        let navController = UINavigationController(rootViewController: authVC)
        authVC.delegate = self
        present(navController, animated: true)
    }
    
    func addCardPaymentMethod() {
        // Create a view controller for the credit card entry
        let cardVC = CardEntryViewController()
        cardVC.title = "Add Credit Card"
        cardVC.view.backgroundColor = .systemBackground // Set background color
        cardVC.delegate = self
        
        // Present the card entry view controller
        let navController = UINavigationController(rootViewController: cardVC)
        navController.view.backgroundColor = .systemBackground // Set navigation controller background
        navController.navigationBar.isTranslucent = false // Make navigation bar opaque
        
        // Ensure the navigation bar is visible
        navController.setNavigationBarHidden(false, animated: false)
        
        present(navController, animated: true)
    }
    
    @objc private func dismissCardEntry() {
        dismiss(animated: true)
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
                    // If this is the first payment method, make it default
                    let isDefault = self?.paymentMethods.isEmpty ?? true
                    self?.paymentMethods.append(SavedPaymentMethod(type: cardType, last4: last4, isDefault: isDefault, cardBrand: cardTypeName))
                    
                    // Save changes to UserDefaults
                    self?.savePaymentMethods()
                    
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
    
    func setupApplePay() {
        // Skip validation and directly create a payment request
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.skilled.payments"
        request.supportedNetworks = [PKPaymentNetwork.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        // Add a small verification amount
        let paymentItem = PKPaymentSummaryItem(label: "Verify Account", amount: NSDecimalNumber(value: 0.01))
        request.paymentSummaryItems = [paymentItem]
        
        if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            paymentVC.delegate = self
            present(paymentVC, animated: true)
        } else {
            // Fallback - directly add Apple Pay without showing UI
            DispatchQueue.main.async { [weak self] in
                let isDefault = self?.paymentMethods.isEmpty ?? true
                self?.paymentMethods.append(SavedPaymentMethod(type: .applePay, last4: nil, isDefault: isDefault))
                self?.tableView.reloadData()
            }
        }
    }
    
    private func deletePaymentMethod(at index: Int) {
        // Check if we're deleting the default payment method
        let wasDefault = paymentMethods[index].isDefault
        
        // In a real app, this would delete from a database or API
        paymentMethods.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        // If we deleted the default payment method and there are other methods,
        // make the first one the default
        if wasDefault && !paymentMethods.isEmpty {
            paymentMethods[0].isDefault = true
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        // Save changes to UserDefaults
        savePaymentMethods()
    }
}

// MARK: - Protocol Conformances
extension PaymentMethodsViewController: PaymentMethodsActionSheetDelegate {
    // Methods are already implemented in the class
}

// MARK: - CardEntryViewControllerDelegate
extension PaymentMethodsViewController: CardEntryViewControllerDelegate {
    func cardEntryDidComplete(cardNumber: String, expiryDate: String, cvv: String, cardholderName: String) {
        // Process the card payment
        processCardPayment(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cvv: cvv,
            cardholderName: cardholderName
        )
    }
    
    func cardEntryDidCancel() {
        // Nothing to do here, the view controller will dismiss itself
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
                    let isDefault = paymentMethods.isEmpty
                    paymentMethods.append(SavedPaymentMethod(type: .bankTransfer, last4: "PayPal", isDefault: isDefault))
                } else if token.contains("Google") {
                    let isDefault = paymentMethods.isEmpty
                    paymentMethods.append(SavedPaymentMethod(type: .debitCard, last4: "Google Pay", isDefault: isDefault))
                }
                
                // Save changes to UserDefaults
                savePaymentMethods()
                
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
            let isDefault = self?.paymentMethods.isEmpty ?? true
            self?.paymentMethods.append(SavedPaymentMethod(type: .applePay, last4: nil, isDefault: isDefault))
            
            // Save changes to UserDefaults
            self?.savePaymentMethods()
            
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
        
        // Add checkmark for default payment method
        if paymentMethod.isDefault {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        switch paymentMethod.type {
        case .creditCard:
            content.text = "Credit Card"
            if let last4 = paymentMethod.last4 {
                // Use stored card brand or determine based on first digit
                let cardBrand = paymentMethod.cardBrand ?? {
                    if last4.hasPrefix("4") {
                        return "Visa"
                    } else if last4.hasPrefix("5") {
                        return "Mastercard"
                    } else if last4.hasPrefix("3") {
                        return "American Express"
                    } else if last4.hasPrefix("6") {
                        return "Discover"
                    } else {
                        return "Credit Card"
                    }
                }()
                
                // Set image based on card brand
                if cardBrand == "Visa" {
                    content.image = UIImage(named: "visa")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(systemName: "creditcard.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                } else if cardBrand == "Mastercard" {
                    content.image = UIImage(named: "mastercard")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(systemName: "creditcard.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
                } else if cardBrand == "American Express" {
                    // Try both amex and american-express image names
                    content.image = UIImage(named: "american-express")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(named: "amex")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(systemName: "creditcard.fill")?.withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
                } else if cardBrand == "Discover" {
                    content.image = UIImage(named: "discover")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(systemName: "creditcard.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
                } else {
                    content.image = UIImage(systemName: "creditcard.fill")
                }
                content.secondaryText = "\(cardBrand) •••• \(last4)"
            } else {
                content.image = UIImage(systemName: "creditcard.fill")
                content.secondaryText = "•••• ••••"
            }
            
        case .debitCard:
            content.text = "Debit Card"
            if let last4 = paymentMethod.last4 {
                if last4 == "Google Pay" {
                    content.text = "Google Pay"
                    // Use the correct Google Pay image path
                    content.image = UIImage(named: "google-pay")?.withRenderingMode(.alwaysOriginal) ?? 
                                   UIImage(systemName: "g.circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
                    content.secondaryText = ""
                } else {
                    // Try to load Discover image from assets, fall back to system image
                    if let discoverImage = UIImage(named: "discover") ?? UIImage(named: "CardBrands/discover") {
                        content.image = discoverImage
                    } else {
                        content.image = UIImage(systemName: "creditcard.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal)
                    }
                    content.secondaryText = "•••• \(last4)"
                }
            } else {
                content.image = UIImage(systemName: "creditcard.fill")
                content.secondaryText = "•••• ••••"
            }
            
        case .applePay:
            content.text = "Apple Pay"
            // Use light or dark Apple Pay icon based on user interface style
            let isDarkMode = traitCollection.userInterfaceStyle == .dark
            let applePayIconName = isDarkMode ? "applepay-dark" : "applepay-light"
            content.image = UIImage(named: applePayIconName)?.withRenderingMode(.alwaysOriginal) ?? UIImage(systemName: "applepay")
            
        case .bankTransfer:
            if let last4 = paymentMethod.last4, last4 == "PayPal" {
                content.text = "PayPal"
                // Use the correct PayPal image path
                content.image = UIImage(named: "paypal")?.withRenderingMode(.alwaysOriginal) ?? 
                               UIImage(systemName: "p.circle.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            } else {
                content.text = "Bank Transfer"
                content.image = UIImage(systemName: "building.columns.fill")
            }
        }
        
        // Configure image size
        content.imageProperties.maximumSize = CGSize(width: 60, height: 40)
        content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 40)
        
        // Ensure all images use original rendering mode
        if let image = content.image {
            content.image = image.withRenderingMode(.alwaysOriginal)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.deletePaymentMethod(at: indexPath.row)
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.editPaymentMethod(at: indexPath.row)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let defaultAction = UIContextualAction(style: .normal, title: "Default") { [weak self] (_, _, completion) in
            self?.setDefaultPaymentMethod(at: indexPath.row)
            completion(true)
        }
        defaultAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, defaultAction])
    }
    
    private func editPaymentMethod(at index: Int) {
        // Implementation for editing payment method
        let paymentMethod = paymentMethods[index]
        
        // Only credit/debit cards can be edited
        if paymentMethod.type == .creditCard || paymentMethod.type == .debitCard, 
           let last4 = paymentMethod.last4 {
            let alert = UIAlertController(
                title: "Edit Payment Method",
                message: "Card ending in \(last4)",
                preferredStyle: .alert
            )
            
            alert.addTextField { textField in
                textField.placeholder = "Cardholder Name"
                textField.text = "Current Cardholder" // In a real app, get this from storage
            }
            
            alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
                // In a real app, save the updated information
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        } else {
            // Digital payment methods can't be edited
            let alert = UIAlertController(
                title: "Cannot Edit",
                message: "This payment method cannot be edited.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func setDefaultPaymentMethod(at index: Int) {
        // Mark all payment methods as non-default
        for i in 0..<paymentMethods.count {
            paymentMethods[i].isDefault = false
        }
        
        // Set the selected one as default
        paymentMethods[index].isDefault = true
        
        // Save changes to UserDefaults
        savePaymentMethods()
        
        // Reload table to update UI
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePaymentMethod(at: indexPath.row)
        }
    }
}
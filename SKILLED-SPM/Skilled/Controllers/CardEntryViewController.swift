import UIKit

protocol CardEntryViewControllerDelegate: AnyObject {
    func cardEntryDidComplete(cardNumber: String, expiryDate: String, cvv: String, cardholderName: String)
    func cardEntryDidCancel()
}

class CardEntryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CardEntryViewControllerDelegate?
    
    // MARK: - UI Components
    private let cardEntryView: CreditCardEntryView = {
        let view = CreditCardEntryView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(cardEntryView)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            cardEntryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardEntryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardEntryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardEntryView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Add scan button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "camera.viewfinder"),
            style: .plain,
            target: self,
            action: #selector(scanCardTapped)
        )
    }
    
    private func setupActions() {
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelTapped() {
        delegate?.cardEntryDidCancel()
        dismiss(animated: true)
    }
    
    // MARK: - Actions
    @objc func submitButtonTapped() {
        guard let cardDetails = cardEntryView.getCardDetails() else {
            showValidationError(message: "Please fill in all card details")
            return
        }
        
        delegate?.cardEntryDidComplete(
            cardNumber: cardDetails.cardNumber,
            expiryDate: cardDetails.expiryDate,
            cvv: cardDetails.cvv,
            cardholderName: cardDetails.name
        )
        
        dismiss(animated: true)
    }
    
    @objc func scanCardTapped() {
        let scannerVC = CardScannerViewController()
        scannerVC.delegate = self
        
        let navController = UINavigationController(rootViewController: scannerVC)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.barStyle = .black
        navController.navigationBar.tintColor = .white
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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
}

// MARK: - CardScannerViewControllerDelegate
extension CardEntryViewController: CardScannerViewControllerDelegate {
    func cardScannerDidScan(cardNumber: String, expiryDate: String, cardholderName: String, cvv: String) {
        cardEntryView.updateWithScannedCard(
            number: cardNumber,
            expiry: expiryDate,
            name: cardholderName,
            cvv: cvv
        )
    }
    
    func cardScannerDidCancel() {
        // Nothing to do here, the scanner will dismiss itself
    }
}
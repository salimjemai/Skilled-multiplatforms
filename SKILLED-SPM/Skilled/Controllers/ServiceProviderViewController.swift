import UIKit
import FirebaseAuth

class ServiceProviderViewController: UIViewController {
    
    // MARK: - Properties
    var client: User?
    
    // MARK: - UI Components
    private let clientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Contact Client", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let offerServiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Offer Service", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Client Details"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        populateData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(clientNameLabel)
        view.addSubview(contactButton)
        view.addSubview(offerServiceButton)
        
        NSLayoutConstraint.activate([
            clientNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            clientNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clientNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contactButton.topAnchor.constraint(equalTo: clientNameLabel.bottomAnchor, constant: 40),
            contactButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            contactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            contactButton.heightAnchor.constraint(equalToConstant: 50),
            
            offerServiceButton.topAnchor.constraint(equalTo: contactButton.bottomAnchor, constant: 20),
            offerServiceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            offerServiceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            offerServiceButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        offerServiceButton.addTarget(self, action: #selector(offerServiceButtonTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        if let client = client {
            clientNameLabel.text = "\(client.firstName) \(client.lastName)"
        } else {
            clientNameLabel.text = "Unknown Client"
        }
    }
    
    // MARK: - Actions
    @objc private func contactButtonTapped() {
        // Check if provider has complete address before contacting
        requireCompleteAddress(for: UserManager.shared.currentUser) {
            // This will only execute if the provider has a complete address
            self.proceedWithContact()
        }
    }
    
    @objc private func offerServiceButtonTapped() {
        // Check if provider has complete address before offering service
        requireCompleteAddress(for: UserManager.shared.currentUser) {
            // This will only execute if the provider has a complete address
            self.proceedWithServiceOffer()
        }
    }
    
    private func proceedWithContact() {
        // Implement contact logic here
        showAlert(title: "Contact Request Sent", message: "The client will be notified of your contact request.")
    }
    
    private func proceedWithServiceOffer() {
        // Implement service offer logic here
        showAlert(title: "Service Offered", message: "Your service offer has been sent to the client.")
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
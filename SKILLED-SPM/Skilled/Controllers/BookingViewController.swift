import UIKit
import FirebaseAuth

class BookingViewController: UIViewController {
    
    // MARK: - Properties
    var service: Service?
    var provider: User?
    
    // MARK: - UI Components
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bookButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Service", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Contact Provider", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Book Service"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        populateData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(serviceNameLabel)
        view.addSubview(providerNameLabel)
        view.addSubview(bookButton)
        view.addSubview(contactButton)
        
        NSLayoutConstraint.activate([
            serviceNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            serviceNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serviceNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 20),
            providerNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            providerNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bookButton.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 40),
            bookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bookButton.heightAnchor.constraint(equalToConstant: 50),
            
            contactButton.topAnchor.constraint(equalTo: bookButton.bottomAnchor, constant: 20),
            contactButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            contactButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            contactButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        bookButton.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        serviceNameLabel.text = service?.name ?? "Service"
        
        if let provider = provider {
            providerNameLabel.text = "\(provider.firstName) \(provider.lastName)"
        } else {
            providerNameLabel.text = "Unknown Provider"
        }
    }
    
    // MARK: - Actions
    @objc private func bookButtonTapped() {
        // Check if user has complete address before booking
        requireCompleteAddress(for: UserManager.shared.currentUser) {
            // This will only execute if the user has a complete address
            self.proceedWithBooking()
        }
    }
    
    @objc private func contactButtonTapped() {
        // Check if user has complete address before contacting
        requireCompleteAddress(for: UserManager.shared.currentUser) {
            // This will only execute if the user has a complete address
            self.proceedWithContact()
        }
    }
    
    private func proceedWithBooking() {
        // Implement booking logic here
        showAlert(title: "Booking Confirmed", message: "Your booking has been confirmed!")
    }
    
    private func proceedWithContact() {
        // Implement contact logic here
        showAlert(title: "Contact Request Sent", message: "The provider will contact you shortly.")
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
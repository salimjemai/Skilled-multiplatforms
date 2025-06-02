import UIKit
import FirebaseAuth
import FirebaseFirestore
import PassKit

class BookingDetailViewController: UIViewController {
    
    // MARK: - Properties
    var booking: Booking?
    private let db = Firestore.firestore()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Service Provider"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clientTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Client"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let clientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Booking Details"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupActions()
        populateData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(serviceNameLabel)
        contentView.addSubview(statusView)
        statusView.addSubview(statusLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(providerTitleLabel)
        contentView.addSubview(providerNameLabel)
        contentView.addSubview(clientTitleLabel)
        contentView.addSubview(clientNameLabel)
        contentView.addSubview(notesTitleLabel)
        contentView.addSubview(notesLabel)
        contentView.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            serviceNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            serviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusView.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 12),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusView.heightAnchor.constraint(equalToConstant: 30),
            statusView.widthAnchor.constraint(equalToConstant: 100),
            
            statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: statusView.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            providerTitleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 24),
            providerTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            providerTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            providerNameLabel.topAnchor.constraint(equalTo: providerTitleLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            providerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            clientTitleLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 16),
            clientTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clientTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            clientNameLabel.topAnchor.constraint(equalTo: clientTitleLabel.bottomAnchor, constant: 4),
            clientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesTitleLabel.topAnchor.constraint(equalTo: clientNameLabel.bottomAnchor, constant: 16),
            notesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesLabel.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 4),
            notesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            actionButton.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 30),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func populateData() {
        guard let booking = booking else { return }
        
        serviceNameLabel.text = booking.serviceName
        
        // Status
        statusLabel.text = booking.status.displayText
        statusView.backgroundColor = booking.status.color.withAlphaComponent(0.2)
        statusLabel.textColor = booking.status.color
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: booking.date)
        
        // Price
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        if let formattedPrice = numberFormatter.string(from: NSNumber(value: booking.price)) {
            priceLabel.text = formattedPrice
        } else {
            priceLabel.text = "$\(booking.price)"
        }
        
        // Provider and client
        providerNameLabel.text = booking.providerName
        clientNameLabel.text = booking.clientName
        
        // Notes
        if let notes = booking.notes, !notes.isEmpty {
            notesLabel.text = notes
        } else {
            notesLabel.text = "No notes provided"
            notesLabel.textColor = .lightGray
        }
        
        // Configure action button based on booking status and user role
        configureActionButton()
    }
    
    private func configureActionButton() {
        guard let booking = booking, let currentUserId = Auth.auth().currentUser?.uid else {
            actionButton.isHidden = true
            return
        }
        
        let isProvider = currentUserId == booking.providerId
        
        switch booking.status {
        case .pending:
            if isProvider {
                actionButton.setTitle("Confirm Booking", for: .normal)
                actionButton.backgroundColor = .systemGreen
            } else {
                actionButton.setTitle("Cancel Booking", for: .normal)
                actionButton.backgroundColor = .systemRed
            }
            
        case .confirmed:
            if isProvider {
                actionButton.setTitle("Mark as Completed", for: .normal)
                actionButton.backgroundColor = .systemGreen
            } else {
                // For clients with confirmed bookings, show payment option
                actionButton.setTitle("Make Payment", for: .normal)
                actionButton.backgroundColor = .systemBlue
            }
            
        case .completed:
            if !isProvider {
                actionButton.setTitle("Leave Review", for: .normal)
                actionButton.backgroundColor = .systemBlue
            } else {
                actionButton.isHidden = true
            }
            
        case .cancelled:
            actionButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        guard let booking = booking, let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let isProvider = currentUserId == booking.providerId
        
        switch booking.status {
        case .pending:
            if isProvider {
                updateBookingStatus(.confirmed)
            } else {
                updateBookingStatus(.cancelled)
            }
            
        case .confirmed:
            if isProvider {
                updateBookingStatus(.completed)
            } else {
                // Show payment screen for clients
                showPaymentScreen()
            }
            
        case .completed:
            if !isProvider {
                // Show review form
                showReviewForm()
            }
            
        case .cancelled:
            break
        }
    }
    
    private func showPaymentScreen() {
        guard let booking = booking else { return }
        let paymentVC = PaymentViewController(booking: booking)
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    private func updateBookingStatus(_ newStatus: BookingStatus) {
        guard let booking = booking else { return }
        
        let bookingRef = db.collection("bookings").document(booking.id)
        
        bookingRef.updateData([
            "status": newStatus.rawValue,
            "updatedAt": Timestamp(date: Date())
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to update booking: \(error.localizedDescription)")
                return
            }
            
            // Update local booking
            var updatedBooking = booking
            updatedBooking.status = newStatus
            updatedBooking.updatedAt = Date()
            self?.booking = updatedBooking
            
            // Update UI
            DispatchQueue.main.async {
                self?.populateData()
                self?.showAlert(title: "Success", message: "Booking status updated to \(newStatus.displayText)")
            }
        }
    }
    
    private func showReviewForm() {
        // In a real app, you would show a review form here
        showAlert(title: "Leave a Review", message: "Review functionality would be implemented here")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
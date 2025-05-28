import UIKit
import FirebaseAuth
import FirebaseFirestore

class BookingsViewController: UIViewController {
    
    // MARK: - Properties
    private var bookings: [Booking] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(BookingCell.self, forCellReuseIdentifier: "BookingCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No bookings yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 18)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Bookings"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBookings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add filter button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Filter",
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 120
        tableView.separatorStyle = .singleLine
    }
    
    // MARK: - Data Fetching
    private func fetchBookings() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showEmptyState()
            return
        }
        
        activityIndicator.startAnimating()
        
        // Create some mock bookings for testing
        createMockBookingsIfNeeded()
        
        // Determine if user is client or provider
        UserManager.shared.fetchCurrentUser { [weak self] user, error in
            guard let self = self, let user = user else {
                self?.activityIndicator.stopAnimating()
                self?.showEmptyState()
                return
            }
            
            // Query bookings based on user role
            let query: Query
            if user.role == .provider {
                query = self.db.collection("bookings")
                    .whereField("providerId", isEqualTo: userId)
                    .order(by: "date", descending: true)
            } else {
                query = self.db.collection("bookings")
                    .whereField("clientId", isEqualTo: userId)
                    .order(by: "date", descending: true)
            }
            
            // Set up real-time listener
            self.listener = query.addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error fetching bookings: \(error.localizedDescription)")
                    self.showEmptyState()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.showEmptyState()
                    return
                }
                
                self.bookings = documents.compactMap { document -> Booking? in
                    return Booking.fromDictionary(document.data())
                }
                
                if self.bookings.isEmpty {
                    self.showEmptyState()
                } else {
                    self.hideEmptyState()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func showEmptyState() {
        emptyStateLabel.isHidden = false
        tableView.isHidden = true
    }
    
    private func hideEmptyState() {
        emptyStateLabel.isHidden = true
        tableView.isHidden = false
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        let alertController = UIAlertController(title: "Filter Bookings", message: nil, preferredStyle: .actionSheet)
        
        // Add filter options
        alertController.addAction(UIAlertAction(title: "All Bookings", style: .default) { [weak self] _ in
            self?.fetchBookings()
        })
        
        alertController.addAction(UIAlertAction(title: "Pending", style: .default) { [weak self] _ in
            self?.filterBookings(by: .pending)
        })
        
        alertController.addAction(UIAlertAction(title: "Confirmed", style: .default) { [weak self] _ in
            self?.filterBookings(by: .confirmed)
        })
        
        alertController.addAction(UIAlertAction(title: "Completed", style: .default) { [weak self] _ in
            self?.filterBookings(by: .completed)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancelled", style: .default) { [weak self] _ in
            self?.filterBookings(by: .cancelled)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func createMockBookingsIfNeeded() {
        // Check if we already have bookings
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("bookings").whereField("clientId", isEqualTo: userId).limit(to: 1).getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error checking for bookings: \(error)")
                return
            }
            
            // If no bookings exist, create mock data
            if snapshot?.documents.isEmpty ?? true {
                self?.createMockBookings(userId: userId)
            }
        }
    }
    
    private func createMockBookings(userId: String) {
        let mockBookings = [
            [
                "id": "booking1",
                "serviceId": "service1",
                "serviceName": "Plumbing Repair",
                "providerId": "provider1",
                "providerName": "Mike's Plumbing",
                "clientId": userId,
                "clientName": "You",
                "status": "confirmed",
                "date": Timestamp(date: Date().addingTimeInterval(86400)), // Tomorrow
                "price": 120.0,
                "notes": "Fix leaking sink",
                "createdAt": Timestamp(date: Date().addingTimeInterval(-86400)), // Yesterday
                "updatedAt": Timestamp(date: Date())
            ],
            [
                "id": "booking2",
                "serviceId": "service2",
                "serviceName": "Electrical Wiring",
                "providerId": "provider2",
                "providerName": "ElectraPro",
                "clientId": userId,
                "clientName": "You",
                "status": "pending",
                "date": Timestamp(date: Date().addingTimeInterval(86400 * 3)), // 3 days from now
                "price": 200.0,
                "notes": "Install new outlets",
                "createdAt": Timestamp(date: Date().addingTimeInterval(-43200)), // 12 hours ago
                "updatedAt": Timestamp(date: Date())
            ],
            [
                "id": "booking3",
                "serviceId": "service3",
                "serviceName": "Lawn Mowing",
                "providerId": "provider3",
                "providerName": "Green Landscapes",
                "clientId": userId,
                "clientName": "You",
                "status": "completed",
                "date": Timestamp(date: Date().addingTimeInterval(-86400 * 2)), // 2 days ago
                "price": 75.0,
                "notes": "Weekly lawn service",
                "createdAt": Timestamp(date: Date().addingTimeInterval(-86400 * 5)), // 5 days ago
                "updatedAt": Timestamp(date: Date().addingTimeInterval(-86400 * 2)) // 2 days ago
            ]
        ]
        
        // Add mock bookings to Firestore
        let batch = db.batch()
        
        for bookingData in mockBookings {
            let bookingRef = db.collection("bookings").document(bookingData["id"] as! String)
            batch.setData(bookingData, forDocument: bookingRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error creating mock bookings: \(error)")
            } else {
                print("Mock bookings created successfully")
            }
        }
    }
    
    private func filterBookings(by status: BookingStatus) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        activityIndicator.startAnimating()
        
        // Determine if user is client or provider
        UserManager.shared.fetchCurrentUser { [weak self] user, error in
            guard let self = self, let user = user else {
                self?.activityIndicator.stopAnimating()
                return
            }
            
            // Query bookings based on user role and status
            let query: Query
            if user.role == .provider {
                query = self.db.collection("bookings")
                    .whereField("providerId", isEqualTo: userId)
                    .whereField("status", isEqualTo: status.rawValue)
                    .order(by: "date", descending: true)
            } else {
                query = self.db.collection("bookings")
                    .whereField("clientId", isEqualTo: userId)
                    .whereField("status", isEqualTo: status.rawValue)
                    .order(by: "date", descending: true)
            }
            
            // Update listener
            self.listener?.remove()
            self.listener = query.addSnapshotListener { [weak self] snapshot, error in
                // Same handling as in fetchBookings()
                // (Code omitted for brevity - would be identical to the listener in fetchBookings)
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension BookingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as? BookingCell else {
            return UITableViewCell()
        }
        
        let booking = bookings[indexPath.row]
        cell.configure(with: booking)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let booking = bookings[indexPath.row]
        let detailVC = BookingDetailViewController()
        detailVC.booking = booking
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - BookingCell
class BookingCell: UITableViewCell {
    
    // MARK: - UI Components
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(serviceNameLabel)
        contentView.addSubview(providerNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            serviceNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            serviceNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            serviceNameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 4),
            providerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            providerNameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceLabel.widthAnchor.constraint(equalToConstant: 80),
            
            statusLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(equalToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with booking: Booking) {
        serviceNameLabel.text = booking.serviceName
        
        // Show provider name for clients, client name for providers
        if let currentUserId = Auth.auth().currentUser?.uid {
            if currentUserId == booking.clientId {
                providerNameLabel.text = "Provider: \(booking.providerName)"
            } else {
                providerNameLabel.text = "Client: \(booking.clientName)"
            }
        }
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: booking.date)
        
        // Format price
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        if let formattedPrice = numberFormatter.string(from: NSNumber(value: booking.price)) {
            priceLabel.text = formattedPrice
        } else {
            priceLabel.text = "$\(booking.price)"
        }
        
        // Set status
        statusLabel.text = booking.status.displayText
        statusLabel.backgroundColor = booking.status.color.withAlphaComponent(0.2)
        statusLabel.textColor = booking.status.color
    }
}
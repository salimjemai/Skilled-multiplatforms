import UIKit
import FirebaseAuth

class PaymentsHistoryViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PaymentCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No payment history found"
        label.textAlignment = .center
        label.textColor = .gray
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
    
    // MARK: - Properties
    private let paymentService = PaymentService()
    private var payments: [Payment] = []
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment History"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPayments()
    }
    
    // MARK: - UI Setup
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
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Data Loading
    private func loadPayments() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            showEmptyState()
            return
        }
        
        activityIndicator.startAnimating()
        
        paymentService.getPaymentsForUser(userId: currentUserId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let payments):
                    self.payments = payments.sorted(by: { $0.createdAt > $1.createdAt })
                    
                    if self.payments.isEmpty {
                        self.showEmptyState()
                    } else {
                        self.hideEmptyState()
                    }
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to load payments: \(error.localizedDescription)")
                    self.showEmptyState()
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PaymentsHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath)
        let payment = payments[indexPath.row]
        
        // Configure cell
        var content = cell.defaultContentConfiguration()
        
        // Format amount
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        let amountString = numberFormatter.string(from: NSNumber(value: payment.amount)) ?? "$\(payment.amount)"
        
        content.text = "\(amountString) - \(payment.status.displayText)"
        content.secondaryText = "Date: \(dateFormatter.string(from: payment.createdAt))"
        
        // Set status color
        switch payment.status {
        case .completed:
            content.secondaryTextProperties.color = .systemGreen
        case .pending, .processing:
            content.secondaryTextProperties.color = .systemYellow
        case .failed:
            content.secondaryTextProperties.color = .systemRed
        case .refunded:
            content.secondaryTextProperties.color = .systemGray
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show payment details (could be implemented in a future version)
        let payment = payments[indexPath.row]
        let alert = UIAlertController(
            title: "Payment Details",
            message: """
            Amount: \(payment.amount)
            Status: \(payment.status.displayText)
            Method: \(payment.paymentMethod.rawValue)
            Date: \(dateFormatter.string(from: payment.createdAt))
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
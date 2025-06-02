import UIKit
import FirebaseFirestore

class ServiceProvidersListViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProviderListCell.self, forCellReuseIdentifier: "ProviderListCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var serviceProviders: [User] = []
    private var selectedServiceType: String?
    
    init(serviceType: String? = nil) {
        self.selectedServiceType = serviceType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedServiceType ?? "Service Providers"
        view.backgroundColor = .systemBackground
        
        setupUI()
        fetchOnlineServiceProviders()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchOnlineServiceProviders() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        var query = db.collection("users")
            .whereField("role", isEqualTo: "provider")
        
        // For demo purposes, we're not filtering by online status yet
        // In a real app, you would add: .whereField("isOnline", isEqualTo: true)
        
        if let serviceType = selectedServiceType {
            query = query.whereField("servicesOffered", arrayContains: serviceType)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load service providers: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.showAlert(title: "Error", message: "No service providers found")
                return
            }
            
            self.serviceProviders = documents.compactMap { document in
                let userData = document.data()
                return User(dictionary: userData)
            }
            
            if self.serviceProviders.isEmpty {
                self.showEmptyState()
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No online service providers available at the moment"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func startChat(with provider: User) {
        // Create a new chat or open existing chat
        // This would be implemented in a real app
        showAlert(title: "Chat", message: "Starting chat with \(provider.fullName)")
        
        // In a real app, you would navigate to the chat screen:
        // let chatVC = ChatViewController(recipient: provider)
        // navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ServiceProvidersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderListCell", for: indexPath) as? ProviderListCell else {
            return UITableViewCell()
        }
        
        let provider = serviceProviders[indexPath.row]
        cell.configure(with: provider)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let provider = serviceProviders[indexPath.row]
        startChat(with: provider)
    }
}
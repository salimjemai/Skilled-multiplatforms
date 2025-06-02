import UIKit
import FirebaseFirestore
import FirebaseAuth

class MessagesTabViewController: UIViewController {
    
    private let providersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 90)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ProviderCollectionViewCell.self, forCellWithReuseIdentifier: ProviderCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let providersLabel: UILabel = {
        let label = UILabel()
        label.text = "Service Providers"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatPreviewCell.self, forCellReuseIdentifier: "ChatPreviewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var chatPreviews: [ChatPreview] = []
    private var serviceProviders: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        view.backgroundColor = .systemBackground
        
        // Remove any right bar button items (like + button)
        navigationItem.rightBarButtonItem = nil
        
        setupUI()
        loadChatPreviews()
        loadServiceProviders()
        
        // Register for profile image updates
        NotificationCenter.default.addObserver(self, selector: #selector(refreshProviders), name: NSNotification.Name("ProfileImageUpdated"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure no right bar button items are shown
        navigationItem.rightBarButtonItem = nil
        
        // Refresh providers to show updated images
        providersCollectionView.reloadData()
    }
    
    @objc private func refreshProviders() {
        DispatchQueue.main.async {
            self.providersCollectionView.reloadData()
        }
    }
    
    private func setupUI() {
        view.addSubview(providersLabel)
        view.addSubview(providersCollectionView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            providersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            providersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            providersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            providersCollectionView.topAnchor.constraint(equalTo: providersLabel.bottomAnchor, constant: 5),
            providersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providersCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            tableView.topAnchor.constraint(equalTo: providersCollectionView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        providersCollectionView.delegate = self
        providersCollectionView.dataSource = self
    }
    
    private func loadChatPreviews() {
        activityIndicator.startAnimating()
        
        // Get current user ID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            activityIndicator.stopAnimating()
            return
        }
        
        // Use a simpler query that doesn't require a composite index
        let db = Firestore.firestore()
        
        // Query conversations collection instead
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error loading conversations: \(error.localizedDescription)")
                    
                    // Fallback to dummy data if there's an error
                    self.loadDummyChatPreviews()
                    return
                }
                
                // Process results
                self.chatPreviews = []
                
                if let documents = snapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        let data = document.data()
                        
                        // Extract conversation data
                        if let participants = data["participants"] as? [String],
                           let lastMessage = data["lastMessage"] as? String,
                           let timestamp = data["lastMessageTimestamp"] as? Timestamp {
                            
                            // Get the other participant's ID
                            let otherUserId = participants.first { $0 != currentUserId } ?? ""
                            
                            // Create a chat preview
                            let preview = ChatPreview(
                                userId: otherUserId,
                                name: data["otherUserName"] as? String ?? "User",
                                lastMessage: lastMessage,
                                timestamp: timestamp.dateValue(),
                                unreadCount: data["unreadCount"] as? Int ?? 0
                            )
                            
                            self.chatPreviews.append(preview)
                        }
                    }
                    
                    self.tableView.reloadData()
                } else {
                    // No conversations found, use dummy data
                    self.loadDummyChatPreviews()
                }
            }
    }
    
    private func loadDummyChatPreviews() {
        // Add some dummy chat previews
        self.chatPreviews = [
            ChatPreview(userId: "user1", name: "John Smith", lastMessage: "I'll be there at 2pm", timestamp: Date(), unreadCount: 2),
            ChatPreview(userId: "user2", name: "Sarah Johnson", lastMessage: "The quote looks good", timestamp: Date().addingTimeInterval(-3600), unreadCount: 0),
            ChatPreview(userId: "user3", name: "Mike Brown", lastMessage: "Can you come earlier?", timestamp: Date().addingTimeInterval(-7200), unreadCount: 1)
        ]
        
        self.tableView.reloadData()
    }
    
    private func loadServiceProviders() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("role", isEqualTo: "provider")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    print("Error loading service providers: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.serviceProviders = documents.compactMap { document in
                    let userData = document.data()
                    var user = User(dictionary: userData)
                    
                    // Set availability status based on isAvailableForHire field in database
                    // If not present, default to false
                    if user?.isAvailableForHire == nil {
                        user?.isAvailableForHire = false
                    }
                    
                    return user
                }
                
                self.tableView.reloadData()
            }
    }
    
    private func startChat(with provider: User) {
        let chatVC = ChatViewController()
        chatVC.otherUserId = provider.id
        chatVC.otherUser = provider
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension MessagesTabViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Chats"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatPreviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatPreviewCell", for: indexPath) as? ChatPreviewCell else {
            return UITableViewCell()
        }
        
        let chatPreview = chatPreviews[indexPath.row]
        cell.configure(with: chatPreview)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatPreview = chatPreviews[indexPath.row]
        let chatVC = ChatViewController()
        chatVC.otherUserId = chatPreview.userId
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension MessagesTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceProviders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProviderCollectionViewCell.identifier, for: indexPath) as? ProviderCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let provider = serviceProviders[indexPath.item]
        cell.configure(with: provider)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let provider = serviceProviders[indexPath.item]
        startChat(with: provider)
    }
}
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConversationsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations yet\nTap + to start a new conversation"
        label.numberOfLines = 0
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
    
    // MARK: - Properties
    private var conversations: [Conversation] = []
    private var userCache: [String: User] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Messages"
        view.backgroundColor = .systemBackground
        
        // Initialize Firestore collections
        FirestoreSetupService.shared.setupCollections()
        
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadConversations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChatService.shared.clearListeners()
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
        
        // Add new conversation button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(newConversationTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
    }
    
    // MARK: - Data Loading
    private func loadConversations() {
        activityIndicator.startAnimating()
        
        // Initialize Firestore collections if needed
        FirestoreSetupService.shared.setupCollections()
        
        ChatService.shared.getConversations { [weak self] conversations, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load conversations: \(error.localizedDescription)")
                return
            }
            
            if let conversations = conversations {
                self.conversations = conversations
                
                // Always show empty state for now since we're returning empty arrays
                self.showEmptyState()
                
                /*
                if conversations.isEmpty {
                    self.showEmptyState()
                } else {
                    self.hideEmptyState()
                    self.loadUserData(for: conversations)
                }
                */
            }
        }
    }
    
    private func loadUserData(for conversations: [Conversation]) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Get all unique user IDs that need to be loaded
        var userIds = Set<String>()
        
        for conversation in conversations {
            for participantId in conversation.participants {
                if participantId != currentUserId {
                    userIds.insert(participantId)
                }
            }
        }
        
        // Load user data for each ID
        for userId in userIds {
            if userCache[userId] == nil {
                FirestoreService.shared.getUser(id: userId) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[userId] = user
                        self?.tableView.reloadData()
                    }
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
    @objc private func newConversationTapped() {
        let usersVC = UsersListViewController()
        usersVC.delegate = self
        let navController = UINavigationController(rootViewController: usersVC)
        present(navController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func getOtherUserId(in conversation: Conversation) -> String? {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return nil }
        
        for participantId in conversation.participants {
            if participantId != currentUserId {
                return participantId
            }
        }
        
        return nil
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell else {
            return UITableViewCell()
        }
        
        let conversation = conversations[indexPath.row]
        
        // Get the other user in the conversation
        if let otherUserId = getOtherUserId(in: conversation),
           let otherUser = userCache[otherUserId] {
            cell.configure(with: conversation, otherUser: otherUser)
        } else {
            cell.configure(with: conversation, otherUser: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversation = conversations[indexPath.row]
        
        if let otherUserId = getOtherUserId(in: conversation) {
            let chatVC = ChatViewController()
            chatVC.otherUserId = otherUserId
            chatVC.otherUser = userCache[otherUserId]
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

// MARK: - UsersListViewControllerDelegate
extension ConversationsViewController: UsersListViewControllerDelegate {
    func didSelectUser(_ user: User) {
        let chatVC = ChatViewController()
        chatVC.otherUserId = user.id
        chatVC.otherUser = user
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - ConversationCell
class ConversationCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadBadge)
        unreadBadge.addSubview(unreadCountLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10),
            
            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            lastMessageLabel.trailingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: -10),
            lastMessageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeLabel.widthAnchor.constraint(equalToConstant: 80),
            
            unreadBadge.centerYAnchor.constraint(equalTo: lastMessageLabel.centerYAnchor),
            unreadBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            unreadBadge.widthAnchor.constraint(equalToConstant: 20),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20),
            
            unreadCountLabel.centerXAnchor.constraint(equalTo: unreadBadge.centerXAnchor),
            unreadCountLabel.centerYAnchor.constraint(equalTo: unreadBadge.centerYAnchor)
        ])
    }
    
    func configure(with conversation: Conversation, otherUser: User?) {
        // Set name
        if let otherUser = otherUser {
            nameLabel.text = otherUser.fullName
            
            // Load profile image if available
            if let imageUrl = otherUser.profileImageUrl, let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profileImageView.image = image
                        }
                    }
                }.resume()
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
        } else {
            nameLabel.text = "Unknown User"
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        
        // Set last message
        lastMessageLabel.text = conversation.lastMessage
        
        // Set time
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(conversation.lastMessageTimestamp) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "MM/dd/yy"
        }
        timeLabel.text = formatter.string(from: conversation.lastMessageTimestamp)
        
        // Set unread count
        if let currentUserId = Auth.auth().currentUser?.uid,
           let unreadCount = conversation.unreadCount[currentUserId],
           unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadCountLabel.text = unreadCount > 9 ? "9+" : "\(unreadCount)"
        } else {
            unreadBadge.isHidden = true
        }
    }
}
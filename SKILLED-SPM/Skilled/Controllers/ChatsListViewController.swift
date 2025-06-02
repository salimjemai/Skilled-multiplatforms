import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatsListViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ChatPreviewCell.self, forCellReuseIdentifier: "ChatPreviewCell")
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
    
    private var chatPreviews: [ChatPreview] = []
    private var serviceProviders: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadChatPreviews()
        loadServiceProviders()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadChatPreviews() {
        activityIndicator.startAnimating()
        
        // In a real app, this would fetch chat previews from Firebase
        // For now, we'll use dummy data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.activityIndicator.stopAnimating()
            
            // Add some dummy chat previews
            self.chatPreviews = [
                ChatPreview(userId: "user1", name: "John Smith", lastMessage: "I'll be there at 2pm", timestamp: Date(), unreadCount: 2),
                ChatPreview(userId: "user2", name: "Sarah Johnson", lastMessage: "The quote looks good", timestamp: Date().addingTimeInterval(-3600), unreadCount: 0),
                ChatPreview(userId: "user3", name: "Mike Brown", lastMessage: "Can you come earlier?", timestamp: Date().addingTimeInterval(-7200), unreadCount: 1)
            ]
            
            self.tableView.reloadData()
        }
    }
    
    private func loadServiceProviders() {
        // Create dummy service providers with availability status
        let provider1 = User(
            id: "p1", 
            firstName: "John", 
            lastName: "Plumber", 
            email: "john@example.com", 
            role: .provider, 
            isVerified: true, 
            createdAt: Date(), 
            updatedAt: Date(), 
            servicesOffered: ["Plumbing"], 
            isAvailableForHire: true
        )
        
        let provider2 = User(
            id: "p2", 
            firstName: "Sarah", 
            lastName: "Electrician", 
            email: "sarah@example.com", 
            role: .provider, 
            isVerified: true, 
            createdAt: Date(), 
            updatedAt: Date(), 
            servicesOffered: ["Electrical"], 
            isAvailableForHire: false
        )
        
        let provider3 = User(
            id: "p3", 
            firstName: "Mike", 
            lastName: "Carpenter", 
            email: "mike@example.com", 
            role: .provider, 
            isVerified: true, 
            createdAt: Date(), 
            updatedAt: Date(), 
            servicesOffered: ["Carpentry"], 
            isAvailableForHire: true
        )
        
        self.serviceProviders = [provider1, provider2, provider3]
        self.tableView.reloadData()
    }
    
    private func startChat(with provider: User) {
        let chatVC = ChatViewController()
        chatVC.otherUserId = provider.id
        chatVC.otherUser = provider
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Recent Chats" : "Available Service Providers"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? chatPreviews.count : serviceProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatPreviewCell", for: indexPath) as? ChatPreviewCell else {
                return UITableViewCell()
            }
            
            let chatPreview = chatPreviews[indexPath.row]
            cell.configure(with: chatPreview)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderListCell", for: indexPath) as? ProviderListCell else {
                return UITableViewCell()
            }
            
            let provider = serviceProviders[indexPath.row]
            cell.configure(with: provider)
            
            // Set online/offline indicator
            if let isAvailable = provider.isAvailableForHire {
                cell.onlineIndicator.backgroundColor = isAvailable ? .systemGreen : .systemRed
                cell.onlineIndicator.isHidden = false
            } else {
                cell.onlineIndicator.isHidden = true
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let chatPreview = chatPreviews[indexPath.row]
            let chatVC = ChatViewController()
            chatVC.otherUserId = chatPreview.userId
            navigationController?.pushViewController(chatVC, animated: true)
        } else {
            let provider = serviceProviders[indexPath.row]
            startChat(with: provider)
        }
    }
}

// MARK: - ChatPreviewCell
class ChatPreviewCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
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
        contentView.addSubview(messageLabel)
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
            
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: unreadBadge.leadingAnchor, constant: -10),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15),
            
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeLabel.widthAnchor.constraint(equalToConstant: 80),
            
            unreadBadge.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            unreadBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            unreadBadge.widthAnchor.constraint(equalToConstant: 20),
            unreadBadge.heightAnchor.constraint(equalToConstant: 20),
            
            unreadCountLabel.centerXAnchor.constraint(equalTo: unreadBadge.centerXAnchor),
            unreadCountLabel.centerYAnchor.constraint(equalTo: unreadBadge.centerYAnchor)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure(with chatPreview: ChatPreview) {
        nameLabel.text = chatPreview.name
        messageLabel.text = chatPreview.lastMessage
        
        // Format time
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(chatPreview.timestamp) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "MM/dd/yy"
        }
        timeLabel.text = formatter.string(from: chatPreview.timestamp)
        
        // Show unread badge if there are unread messages
        if chatPreview.unreadCount > 0 {
            unreadBadge.isHidden = false
            unreadCountLabel.text = "\(chatPreview.unreadCount)"
        } else {
            unreadBadge.isHidden = true
        }
    }
}

// MARK: - ChatPreview Model
struct ChatPreview {
    let userId: String
    let name: String
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
}
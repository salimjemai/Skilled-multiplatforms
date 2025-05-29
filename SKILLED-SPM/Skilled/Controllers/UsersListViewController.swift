import UIKit
import FirebaseAuth
import FirebaseFirestore

class UsersListViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search users"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No users found"
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
    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var isSearching = false
    weak var delegate: UsersListViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select User"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupSearchBar()
        setupTableView()
        loadUsers()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Data Loading
    private func loadUsers() {
        activityIndicator.startAnimating()
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            activityIndicator.stopAnimating()
            showEmptyState()
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.showEmptyState()
                return
            }
            
            // Filter out current user
            self.users = documents.compactMap { document -> User? in
                guard let user = User(dictionary: document.data()),
                      user.id != currentUserId else {
                    return nil
                }
                return user
            }
            
            self.filteredUsers = self.users
            
            if self.users.isEmpty {
                self.showEmptyState()
            } else {
                self.hideEmptyState()
                self.tableView.reloadData()
            }
        }
    }
    
    private func filterUsers(with searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
            isSearching = false
        } else {
            isSearching = true
            filteredUsers = users.filter { user in
                let fullName = "\(user.firstName) \(user.lastName)".lowercased()
                return fullName.contains(searchText.lowercased())
            }
        }
        
        if filteredUsers.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
        
        tableView.reloadData()
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
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension UsersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        
        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedUser = filteredUsers[indexPath.row]
        delegate?.didSelectUser(selectedUser)
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension UsersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterUsers(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UserCell
class UserCell: UITableViewCell {
    
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
    
    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        contentView.addSubview(roleLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.fullName
        
        switch user.role {
        case .customer:
            roleLabel.text = "Client"
        case .provider:
            roleLabel.text = "Service Provider"
        case .admin:
            roleLabel.text = "Admin"
        }
        
        // Load profile image if available
        if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
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
    }
}
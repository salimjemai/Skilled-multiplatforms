import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 50
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let serviceTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true // Hidden by default
        return label
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    private var currentUser: User?
    
    // Method to update user data from EditProfileViewController
    func userUpdated(_ user: User) {
        self.currentUser = user
        updateUI(with: user)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user is logged in before loading profile
        if Auth.auth().currentUser != nil {
            loadUserProfile()
        } else {
            // User is not logged in, redirect to login screen
            DispatchQueue.main.async { [weak self] in
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true)
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add UI elements and constraints
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(userTypeLabel)
        view.addSubview(serviceTypeLabel)
        view.addSubview(editProfileButton)
        view.addSubview(signOutButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            userTypeLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            userTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            serviceTypeLabel.topAnchor.constraint(equalTo: userTypeLabel.bottomAnchor, constant: 8),
            serviceTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            serviceTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            editProfileButton.topAnchor.constraint(equalTo: serviceTypeLabel.bottomAnchor, constant: 40),
            editProfileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            editProfileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            editProfileButton.heightAnchor.constraint(equalToConstant: 50),
            
            signOutButton.topAnchor.constraint(equalTo: editProfileButton.bottomAnchor, constant: 20),
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            signOutButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // User is not logged in, redirect to login screen
            DispatchQueue.main.async { [weak self] in
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true)
            }
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUserId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load profile: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let user = User(dictionary: data) else {
                self.showAlert(title: "Error", message: "Failed to parse user data")
                return
            }
            
            self.currentUser = user
            self.updateUI(with: user)
        }
    }
    
    private func updateUI(with user: User) {
        nameLabel.text = user.fullName
        emailLabel.text = user.email
        
        // Set user type
        switch user.role {
        case .customer:
            userTypeLabel.text = "Client Account"
        case .provider:
            userTypeLabel.text = "Service Provider Account"
            
            // Show service types if available
            if let services = user.servicesOffered, !services.isEmpty {
                let serviceTypes = services.map { $0.categoryDisplayName }.joined(separator: ", ")
                serviceTypeLabel.text = "Services: \(serviceTypes)"
                serviceTypeLabel.isHidden = false
            }
        case .admin:
            userTypeLabel.text = "Admin Account"
        }
        
        // Load profile image if available
        if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
            // In a real app, use a proper image loading library like Kingfisher or SDWebImage
            // For now, just show the placeholder
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    // MARK: - Actions
    @objc private func editProfileTapped() {
        guard let currentUser = currentUser else {
            showAlert(title: "Error", message: "User data not available")
            return
        }
        
        let editProfileVC = EditProfileViewController()
        editProfileVC.user = currentUser
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func signOutTapped() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Present the login screen
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            
            // Post notification to update app state
            NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
        } catch {
            showAlert(title: "Error", message: "Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
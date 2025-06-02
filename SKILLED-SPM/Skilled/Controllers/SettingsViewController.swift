import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(ProfileHeaderView.self, forHeaderFooterViewReuseIdentifier: "ProfileHeaderView")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private var currentUser: User?
    private let sections = ["Profile", "Chat Settings", "Booking Settings", "Search Settings", "Legal", "Support"]
    private let sectionItems: [[String]] = [
        ["Edit Profile", "Verification", "Address"],
        ["Notifications", "Message Privacy"],
        ["Payment Methods", "Payment History", "Preferences"],
        ["Search History", "Saved Searches", "Location Settings"],
        ["Terms of Service", "Privacy Policy"],
        ["Contact Support", "Rate App", "About Us", "Sign Out"]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        setupUI()
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear any existing right bar button item
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Data Loading
    private func loadUserProfile() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // User is not logged in, redirect to login screen
            presentLoginScreen()
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUserId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load profile: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  var user = User(dictionary: data) else {
                self.showAlert(title: "Error", message: "Failed to parse user data")
                return
            }
            
            // Force set isVerified to true for testing
            user.isVerified = true
            
            self.currentUser = user
            self.tableView.reloadData()
            
            // Update profile images in all tabs
            ProfileImageManager.shared.updateProfileImageForAllTabs()
        }
    }
    
    private func presentLoginScreen() {
        DispatchQueue.main.async { [weak self] in
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            navController.modalPresentationStyle = .fullScreen
            self?.present(navController, animated: true)
        }
    }
    
    // MARK: - Actions
    private func handleSettingsTap(at indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0: // Profile section
            handleProfileSettings(at: row)
        case 1: // Chat Settings
            handleChatSettings(at: row)
        case 2: // Booking Settings
            handleBookingSettings(at: row)
        case 3: // Search Settings
            handleSearchSettings(at: row)
        case 4: // Legal section
            handleAppSettings(at: row)
        case 5: // Support section
            handleSupportSettings(at: row)
        default:
            break
        }
    }
    
    private func handleProfileSettings(at row: Int) {
        switch row {
        case 0: // Edit Profile
            guard let currentUser = currentUser else { return }
            let editProfileVC = EditProfileViewController()
            editProfileVC.user = currentUser
            navigationController?.pushViewController(editProfileVC, animated: true)
        case 1: // Verification
            showAlert(title: "Verification", message: "Verification features coming soon")
        case 2: // Address
            showAlert(title: "Address", message: "Address management coming soon")
        default:
            break
        }
    }
    
    private func handleChatSettings(at row: Int) {
        showAlert(title: "Chat Settings", message: "Chat settings coming soon")
    }
    
    private func handleBookingSettings(at row: Int) {
        switch row {
        case 0: // Payment Methods
            let paymentMethodsVC = PaymentMethodsViewController()
            navigationController?.pushViewController(paymentMethodsVC, animated: true)
        case 1: // Payment History
            let paymentsHistoryVC = PaymentsHistoryViewController()
            navigationController?.pushViewController(paymentsHistoryVC, animated: true)
        case 2: // Preferences
            showAlert(title: "Preferences", message: "Booking preferences coming soon")
        default:
            break
        }
    }
    
    private func handleSearchSettings(at row: Int) {
        showAlert(title: "Search Settings", message: "Search settings coming soon")
    }
    
    private func handleAppSettings(at row: Int) {
        switch row {
        case 0: // Terms of Service
            let termsVC = TermsOfServiceViewController()
            navigationController?.pushViewController(termsVC, animated: true)
        case 1: // Privacy Policy
            let privacyVC = PrivacyPolicyViewController()
            navigationController?.pushViewController(privacyVC, animated: true)
        default:
            break
        }
    }
    
    private func handleSupportSettings(at row: Int) {
        switch row {
        case 0: // Contact Support
            showAlert(title: "Contact Support", message: "Support features coming soon")
        case 1: // Rate App
            let rateAppVC = RateAppViewController()
            navigationController?.pushViewController(rateAppVC, animated: true)
        case 2: // About Us
            let aboutUsVC = AboutUsViewController()
            navigationController?.pushViewController(aboutUsVC, animated: true)
        case 3: // Sign Out
            signOut()
        default:
            break
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
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

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = sectionItems[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        // Make sign out button red
        if indexPath.section == 5 && indexPath.row == 3 {
            cell.textLabel?.textColor = .systemRed
        } else {
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ProfileHeaderView") as? ProfileHeaderView else {
                return nil
            }
            
            if let user = currentUser {
                headerView.configure(with: user)
            }
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 150 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        handleSettingsTap(at: indexPath)
    }
}

// MARK: - ProfileHeaderView
class ProfileHeaderView: UITableViewHeaderFooterView {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 40
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verifiedBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.seal.fill")
        imageView.tintColor = .systemGreen
        imageView.backgroundColor = .white
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(verifiedBadge)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Add verified badge to the bottom right of profile image
            verifiedBadge.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            verifiedBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 24),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with user: User) {
        nameLabel.text = user.fullName
        emailLabel.text = user.email
        
        // Force show verified badge for testing
        verifiedBadge.isHidden = false
        
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
            // Set default image if no profile image is available
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemBlue
        }
        
        // Print debug info
        print("User verification status: \(user.isVerified)")
        print("Verified badge hidden: \(verifiedBadge.isHidden)")
    }
}
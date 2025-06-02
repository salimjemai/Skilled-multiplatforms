import UIKit

class ProviderCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProviderCollectionViewCell"
    
    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statusIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusIndicator)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 60),
            profileImageView.heightAnchor.constraint(equalToConstant: 60),
            
            statusIndicator.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            statusIndicator.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    // MARK: - Configuration
    func configure(with provider: User) {
        nameLabel.text = provider.firstName
        
        // Set status indicator
        if let isAvailable = provider.isAvailableForHire {
            statusIndicator.backgroundColor = isAvailable ? .systemGreen : .systemRed
            statusIndicator.isHidden = false
        } else {
            statusIndicator.isHidden = true
        }
        
        // Load profile image if available
        if let imageUrl = provider.profileImageUrl {
            if imageUrl.hasPrefix("data:image") {
                // Handle data URL
                let components = imageUrl.components(separatedBy: ",")
                if components.count > 1, let data = Data(base64Encoded: components[1]) {
                    profileImageView.image = UIImage(data: data)
                }
            } else if let url = URL(string: imageUrl) {
                // Handle remote URL
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profileImageView.image = image
                        }
                    }
                }.resume()
            }
        } else {
            // Check if we have a cached image in UserDefaults
            if let imageData = UserDefaults.standard.data(forKey: "profileImage_\(provider.id)"),
               let image = UIImage(data: imageData) {
                profileImageView.image = image
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
                profileImageView.tintColor = .systemBlue
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        nameLabel.text = nil
        statusIndicator.isHidden = true
    }
}
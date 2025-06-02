import UIKit

class ProviderListCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let servicesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let onlineIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let chatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        contentView.addSubview(servicesLabel)
        contentView.addSubview(onlineIndicator)
        contentView.addSubview(chatButton)
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            onlineIndicator.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            onlineIndicator.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            onlineIndicator.widthAnchor.constraint(equalToConstant: 10),
            onlineIndicator.heightAnchor.constraint(equalToConstant: 10),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: chatButton.leadingAnchor, constant: -10),
            
            servicesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            servicesLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            servicesLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            chatButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chatButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            chatButton.widthAnchor.constraint(equalToConstant: 40),
            chatButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        accessoryType = .disclosureIndicator
    }
    
    func configure(with provider: User) {
        nameLabel.text = provider.fullName
        
        if let services = provider.servicesOffered {
            servicesLabel.text = services.joined(separator: ", ")
        } else {
            servicesLabel.text = "No services listed"
        }
        
        // Set online/offline status
        if let isAvailable = provider.isAvailableForHire {
            onlineIndicator.backgroundColor = isAvailable ? .systemGreen : .systemRed
            onlineIndicator.isHidden = false
        } else {
            // Default to online if not specified
            onlineIndicator.backgroundColor = .systemGreen
            onlineIndicator.isHidden = false
        }
        
        // Load profile image if available
        if let imageUrl = provider.profileImageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }.resume()
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .systemBlue
        }
    }
}
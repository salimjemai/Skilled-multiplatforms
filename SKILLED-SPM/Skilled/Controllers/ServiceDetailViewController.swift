import UIKit

class ServiceDetailViewController: UIViewController {
    
    // MARK: - Properties
    var serviceProvider: ServiceProvider?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let businessNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verificationBadgesView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let backgroundCheckBadge = BadgeView(title: "Background Check", iconName: "checkmark.shield.fill")
    private let insuranceBadge = BadgeView(title: "Insured", iconName: "lock.shield.fill")
    private let experienceBadge = BadgeView(title: "Experience", iconName: "clock.fill")
    
    private let sectionTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let servicesLabel: UILabel = {
        let label = UILabel()
        label.text = "Services"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let servicesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 180)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let reviewsLabel: UILabel = {
        let label = UILabel()
        label.text = "Reviews"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reviewsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let bookNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Book Now", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Mock Data
    private var mockServices: [TradeService] = []
    private var mockReviews: [Review] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
        setupTableView()
        setupMockData()
        configureUI()
        
        // Add action for book now button
        bookNowButton.addTarget(self, action: #selector(bookNowButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerImageView)
        contentView.addSubview(profileImageView)
        contentView.addSubview(businessNameLabel)
        contentView.addSubview(ratingView)
        contentView.addSubview(verificationBadgesView)
        
        ratingView.addArrangedSubview(starImageView)
        ratingView.addArrangedSubview(ratingLabel)
        
        verificationBadgesView.addArrangedSubview(backgroundCheckBadge)
        verificationBadgesView.addArrangedSubview(insuranceBadge)
        verificationBadgesView.addArrangedSubview(experienceBadge)
        
        contentView.addSubview(sectionTitleView)
        sectionTitleView.addSubview(sectionTitleLabel)
        contentView.addSubview(descriptionLabel)
        
        contentView.addSubview(servicesLabel)
        contentView.addSubview(servicesCollectionView)
        
        contentView.addSubview(reviewsLabel)
        contentView.addSubview(reviewsTableView)
        
        view.addSubview(bookNowButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bookNowButton.topAnchor, constant: -10),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 150),
            
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: headerImageView.bottomAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            businessNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15),
            businessNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            businessNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingView.topAnchor.constraint(equalTo: businessNameLabel.bottomAnchor, constant: 5),
            ratingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            starImageView.widthAnchor.constraint(equalToConstant: 20),
            starImageView.heightAnchor.constraint(equalToConstant: 20),
            
            verificationBadgesView.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 20),
            verificationBadgesView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            sectionTitleView.topAnchor.constraint(equalTo: verificationBadgesView.bottomAnchor, constant: 20),
            sectionTitleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sectionTitleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sectionTitleView.heightAnchor.constraint(equalToConstant: 40),
            
            sectionTitleLabel.leadingAnchor.constraint(equalTo: sectionTitleView.leadingAnchor, constant: 15),
            sectionTitleLabel.centerYAnchor.constraint(equalTo: sectionTitleView.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: sectionTitleView.bottomAnchor, constant: 15),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            servicesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            servicesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            
            servicesCollectionView.topAnchor.constraint(equalTo: servicesLabel.bottomAnchor, constant: 10),
            servicesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            servicesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            servicesCollectionView.heightAnchor.constraint(equalToConstant: 180),
            
            reviewsLabel.topAnchor.constraint(equalTo: servicesCollectionView.bottomAnchor, constant: 20),
            reviewsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            
            reviewsTableView.topAnchor.constraint(equalTo: reviewsLabel.bottomAnchor, constant: 10),
            reviewsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reviewsTableView.heightAnchor.constraint(equalToConstant: 300),
            reviewsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            bookNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bookNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bookNowButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            bookNowButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupCollectionView() {
        servicesCollectionView.delegate = self
        servicesCollectionView.dataSource = self
        servicesCollectionView.register(ServiceCell.self, forCellWithReuseIdentifier: "ServiceCell")
    }
    
    private func setupTableView() {
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        reviewsTableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
    }
    
    private func setupMockData() {
        // Create mock services
        mockServices = [
            TradeService(id: "1", 
                        name: "Basic Plumbing", 
                         description: "Standard plumbing repairs and installations",
                         providerId: "Provide Id#1",
                        category: .plumbing,
                        pricing: ServicePricing(pricingType: .hourly, basePrice: 85, hourlyRate: 85, minimumFee: 85, estimatedCostRange: nil),
                        estimatedDuration: 60,
                        imageUrls: nil,
                        isActive: true,
                        createdAt: Date(),
                        updatedAt: Date()),
            
            TradeService(id: "2", 
                        name: "Emergency Service", 
                         description: "24/7 emergency plumbing services",
                         providerId: "Provide Id#2",
                        category: .plumbing,
                        pricing: ServicePricing(pricingType: .hourly, basePrice: 150, hourlyRate: 150, minimumFee: 150, estimatedCostRange: nil),
                        estimatedDuration: 90,
                        imageUrls: nil,
                        isActive: true,
                        createdAt: Date(),
                        updatedAt: Date()),
            
            TradeService(id: "3", 
                        name: "Fixture Installation", 
                         description: "Installation of sinks, toilets, and fixtures",
                         providerId: "Provide Id#3",
                        category: .plumbing,
                        pricing: ServicePricing(pricingType: .flat, basePrice: 250, hourlyRate: nil, minimumFee: nil, estimatedCostRange: nil),
                        estimatedDuration: 120,
                        imageUrls: nil,
                        isActive: true,
                        createdAt: Date(),
                        updatedAt: Date())
        ]
        
        // Create mock reviews
        mockReviews = [
            Review(id: "1", 
                  userId: "user1", 
                  providerUserId: "provider1",
                  bookingId: "booking1",
                  rating: 5,
                  comment: "Excellent service! Mike was professional, prompt, and fixed our issue quickly.",
                  responseFromProvider: nil,
                  isVerifiedBooking: true,
                  createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
                  updatedAt: Date().addingTimeInterval(-86400 * 7)),
            
            Review(id: "2", 
                  userId: "user2", 
                  providerUserId: "provider1",
                  bookingId: "booking2",
                  rating: 4,
                  comment: "Good work, but arrived a bit late. Everything works perfectly now though.",
                  responseFromProvider: ReviewResponse(id: "r1", 
                                                     reviewId: "2",
                                                     providerUserId: "provider1",
                                                     responseText: "Thank you for your feedback. I apologize for running late and will strive to be more punctual in future appointments.",
                                                     createdAt: Date().addingTimeInterval(-86400 * 4)), // 4 days ago
                  isVerifiedBooking: true,
                  createdAt: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                  updatedAt: Date().addingTimeInterval(-86400 * 5)),
            
            Review(id: "3", 
                  userId: "user3", 
                  providerUserId: "provider1",
                  bookingId: "booking3",
                  rating: 5,
                  comment: "Mike saved the day with our emergency plumbing issue! Highly recommend.",
                  responseFromProvider: nil,
                  isVerifiedBooking: true,
                  createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                  updatedAt: Date().addingTimeInterval(-86400 * 2))
        ]
    }
    
    private func configureUI() {
        guard let provider = serviceProvider else { return }
        
        // Set the provider details
        title = provider.businessName
        businessNameLabel.text = provider.businessName
        ratingLabel.text = "\(provider.averageRating) (\(provider.totalReviews) reviews)"
        descriptionLabel.text = provider.description
        
        // Configure verification badges
        backgroundCheckBadge.isVerified = provider.backgroundCheckVerified
        insuranceBadge.isVerified = provider.insuranceVerified
        experienceBadge.setValue("\(provider.yearsOfExperience) yrs")
        
        // Set placeholder images
        headerImageView.image = UIImage(named: "header_placeholder") ?? UIImage(systemName: "building.2.fill")
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        
        // Reload collection and table views
        servicesCollectionView.reloadData()
        reviewsTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @objc private func bookNowButtonTapped() {
        let bookingVC = BookingViewController()
        // Convert ServiceProvider to User for BookingViewController
        if let provider = serviceProvider {
            let user = User(
                id: provider.id,
                firstName: "Provider", // Use default values since ServiceProvider doesn't have these fields
                lastName: provider.businessName,
                email: provider.email,
                phoneNumber: provider.phoneNumber,
                profileImageUrl: provider.profileImageUrl,
                role: .provider,
                location: provider.location,
                isVerified: provider.isVerified,
                createdAt: provider.createdAt,
                updatedAt: provider.updatedAt,
                businessName: provider.businessName,
                businessDescription: provider.description,
                yearsOfExperience: provider.yearsOfExperience,
                servicesOffered: provider.tradeCategories
            )
            bookingVC.provider = user
        }
        navigationController?.pushViewController(bookingVC, animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ServiceDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockServices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as? ServiceCell else {
            return UICollectionViewCell()
        }
        
        let service = mockServices[indexPath.item]
        cell.configure(with: service)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let service = mockServices[indexPath.item]
        let bookingVC = BookingViewController()
        
        // Convert ServiceProvider to User for BookingViewController
        if let provider = serviceProvider {
            let user = User(
                id: provider.id,
                firstName: "Provider", // Use default values since ServiceProvider doesn't have these fields
                lastName: provider.businessName,
                email: provider.email,
                phoneNumber: provider.phoneNumber,
                profileImageUrl: provider.profileImageUrl,
                role: .provider,
                location: provider.location,
                isVerified: provider.isVerified,
                createdAt: provider.createdAt,
                updatedAt: provider.updatedAt,
                businessName: provider.businessName,
                businessDescription: provider.description,
                yearsOfExperience: provider.yearsOfExperience,
                servicesOffered: provider.tradeCategories
            )
            bookingVC.provider = user
        }
        
        // Set the selected service
        bookingVC.service = service
        
        navigationController?.pushViewController(bookingVC, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
extension ServiceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            return UITableViewCell()
        }
        
        let review = mockReviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Dynamic height based on content
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - BadgeView
class BadgeView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var isVerified: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    init(title: String, iconName: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        
        setupView()
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updateAppearance() {
        iconImageView.tintColor = isVerified ? .systemGreen : .systemGray3
        titleLabel.textColor = isVerified ? .label : .secondaryLabel
    }
    
    func setValue(_ value: String) {
        titleLabel.text = value
        isVerified = true
    }
}

// MARK: - ServiceCell
class ServiceCell: UICollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            durationLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            durationLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with service: TradeService) {
        nameLabel.text = service.name
        
        // Configure price based on pricing type
        switch service.pricing.pricingType {
        case .flat:
            priceLabel.text = "$\(service.pricing.basePrice)"
        case .hourly:
            if let hourlyRate = service.pricing.hourlyRate {
                priceLabel.text = "$\(hourlyRate)/hr"
            }
        case .estimate:
            if let range = service.pricing.estimatedCostRange {
                priceLabel.text = "$\(range.minimum) - $\(range.maximum)"
            }
        }
        
        // Format duration
        if let minutes = service.estimatedDuration {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if hours > 0 {
                durationLabel.text = "\(hours)h \(remainingMinutes)m"
            } else {
                durationLabel.text = "\(minutes)m"
            }
        } else {
            durationLabel.text = "Varies"
        }
        
        // Set a placeholder image
        imageView.image = UIImage(systemName: "wrench.and.screwdriver.fill")
    }
}

// MARK: - ReviewCell
class ReviewCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let reviewerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let reviewerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "John D."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let responseContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let responseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verifiedBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.seal.fill")
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(reviewerImageView)
        containerView.addSubview(reviewerNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(starsView)
        containerView.addSubview(commentLabel)
        containerView.addSubview(verifiedBadge)
        
        responseContainerView.addSubview(responseLabel)
        
        // Create star images
        for _ in 1...5 {
            let starImageView = UIImageView()
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = .systemYellow
            starsView.addArrangedSubview(starImageView)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            reviewerImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            reviewerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            reviewerImageView.widthAnchor.constraint(equalToConstant: 40),
            reviewerImageView.heightAnchor.constraint(equalToConstant: 40),
            
            reviewerNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            reviewerNameLabel.leadingAnchor.constraint(equalTo: reviewerImageView.trailingAnchor, constant: 10),
            
            verifiedBadge.centerYAnchor.constraint(equalTo: reviewerNameLabel.centerYAnchor),
            verifiedBadge.leadingAnchor.constraint(equalTo: reviewerNameLabel.trailingAnchor, constant: 5),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 16),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: reviewerNameLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: reviewerNameLabel.leadingAnchor),
            
            starsView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            starsView.leadingAnchor.constraint(equalTo: reviewerNameLabel.leadingAnchor),
            starsView.heightAnchor.constraint(equalToConstant: 16),
            
            commentLabel.topAnchor.constraint(equalTo: starsView.bottomAnchor, constant: 8),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        // Response container will be added dynamically when needed
    }
    
    func configure(with review: Review) {
        commentLabel.text = review.comment
        
        // Format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: review.createdAt)
        
        // Configure star rating
        for (index, starView) in starsView.arrangedSubviews.enumerated() {
            if let starImageView = starView as? UIImageView {
                // Fill stars based on rating
                if index < review.rating {
                    starImageView.image = UIImage(systemName: "star.fill")
                } else {
                    starImageView.image = UIImage(systemName: "star")
                }
            }
        }
        
        // Show verified badge if it's a verified booking
        verifiedBadge.isHidden = !review.isVerifiedBooking
        
        // Configure reviewer image
        reviewerImageView.image = UIImage(systemName: "person.crop.circle.fill")
        
        // Add response if available
        if let response = review.responseFromProvider {
            // Add response container if not already added
            if responseContainerView.superview == nil {
                containerView.addSubview(responseContainerView)
                
                NSLayoutConstraint.activate([
                    responseContainerView.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 12),
                    responseContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                    responseContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                    responseContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
                    
                    responseLabel.topAnchor.constraint(equalTo: responseContainerView.topAnchor, constant: 10),
                    responseLabel.leadingAnchor.constraint(equalTo: responseContainerView.leadingAnchor, constant: 10),
                    responseLabel.trailingAnchor.constraint(equalTo: responseContainerView.trailingAnchor, constant: -10),
                    responseLabel.bottomAnchor.constraint(equalTo: responseContainerView.bottomAnchor, constant: -10)
                ])
            }
            
            responseLabel.text = "Response: \(response.responseText)"
            responseContainerView.isHidden = false
            
        } else if responseContainerView.superview != nil {
            responseContainerView.isHidden = true
        } else {
            // Set bottom constraint for comment label if no response
            NSLayoutConstraint.activate([
                commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
        }
    }
}

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Skilled"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find skilled professionals for any job"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Plumbing, electrical, carpentry..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 15
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let featuredProvidersLabel: UILabel = {
        let label = UILabel()
        label.text = "Top Service Providers"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providersTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private var categories: [TradeCategory] = TradeCategory.allCases
    private var featuredProviders: [ServiceProvider] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupCollectionView()
        setupTableView()
        
        // Load featured providers
        loadFeaturedProviders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(welcomeLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(searchBar)
        view.addSubview(categoriesCollectionView)
        view.addSubview(featuredProvidersLabel)
        view.addSubview(providersTableView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchBar.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            featuredProvidersLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 20),
            featuredProvidersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            featuredProvidersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            providersTableView.topAnchor.constraint(equalTo: featuredProvidersLabel.bottomAnchor, constant: 10),
            providersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Skilled"
        
        // Set up right nav bar items
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.circle"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(profileButtonTapped))
        
        let notificationsButton = UIBarButtonItem(image: UIImage(systemName: "bell"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(notificationsButtonTapped))
        
        navigationItem.rightBarButtonItems = [profileButton, notificationsButton]
    }
    
    private func setupCollectionView() {
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
    }
    
    private func setupTableView() {
        providersTableView.delegate = self
        providersTableView.dataSource = self
        providersTableView.register(ServiceProviderCell.self, forCellReuseIdentifier: "ServiceProviderCell")
    }
    
    // MARK: - Data Loading
    private func loadFeaturedProviders() {
        // In a real app, this would make an API call
        // For now, let's create some mock data
        
        // This would be replaced with actual API calls in a real implementation
        let mockData = [
            ServiceProvider(id: "1", 
                           userId: "101", 
                           businessName: "Mike's Plumbing", 
                           description: "Professional plumbing services with 15 years experience",
                           services: nil,
                           averageRating: 4.8,
                           totalReviews: 152,
                           tradeCategories: ["plumbing"],
                           yearsOfExperience: 15,
                           licenses: nil,
                           insuranceVerified: true,
                           backgroundCheckVerified: true,
                           availableTimes: nil,
                           profileCompleted: true,
                           isActive: true,
                           createdAt: Date(),
                           updatedAt: Date()),
            
            ServiceProvider(id: "2", 
                           userId: "102", 
                           businessName: "ElectraPro", 
                           description: "Licensed electricians for residential and commercial work",
                           services: nil,
                           averageRating: 4.6,
                           totalReviews: 98,
                           tradeCategories: ["electrical"],
                           yearsOfExperience: 10,
                           licenses: nil,
                           insuranceVerified: true,
                           backgroundCheckVerified: true,
                           availableTimes: nil,
                           profileCompleted: true,
                           isActive: true,
                           createdAt: Date(),
                           updatedAt: Date()),
            
            ServiceProvider(id: "3", 
                           userId: "103", 
                           businessName: "Green Landscapes", 
                           description: "Complete landscaping solutions for beautiful yards",
                           services: nil,
                           averageRating: 4.9,
                           totalReviews: 76,
                           tradeCategories: ["landscaping"],
                           yearsOfExperience: 8,
                           licenses: nil,
                           insuranceVerified: true,
                           backgroundCheckVerified: true,
                           availableTimes: nil,
                           profileCompleted: true,
                           isActive: true,
                           createdAt: Date(),
                           updatedAt: Date()),
        ]
        
        featuredProviders = mockData
        providersTableView.reloadData()
    }
    
    // MARK: - Action Methods
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func notificationsButtonTapped() {
        // Navigate to notifications
        print("Notifications tapped")
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        let serviceListVC = ServiceListViewController()
        serviceListVC.selectedCategory = selectedCategory
        navigationController?.pushViewController(serviceListVC, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuredProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceProviderCell", for: indexPath) as? ServiceProviderCell else {
            return UITableViewCell()
        }
        
        let provider = featuredProviders[indexPath.row]
        cell.configure(with: provider)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let provider = featuredProviders[indexPath.row]
        let detailVC = ServiceDetailViewController()
        detailVC.serviceProvider = provider
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - String Category Helper
extension String {
    var categoryDisplayName: String {
        switch self {
        case "hvac":
            return "HVAC"
        case "pest":
            return "Pest Control"
        default:
            // Capitalize first letter
            let firstChar = self.prefix(1).uppercased()
            let remainingChars = self.dropFirst()
            return firstChar + remainingChars
        }
    }
    
    var categoryIconName: String {
        switch self {
        case "plumbing":
            return "drop.fill"
        case "electrical":
            return "bolt.fill"
        case "carpentry":
            return "hammer.fill"
        case "painting":
            return "paintbrush.fill"
        case "landscaping":
            return "leaf.fill"
        case "roofing":
            return "house.fill"
        case "hvac":
            return "thermometer.sun.fill"
        case "cleaning":
            return "sparkles"
        case "handyman":
            return "wrench.fill"
        case "masonry":
            return "brick.fill"
        case "flooring":
            return "square.grid.3x3.fill"
        case "moving":
            return "shippingbox.fill"
        case "pest":
            return "ant.fill"
        case "appliance":
            return "washer.fill"
        default:
            return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - CategoryCell
class CategoryCell: UICollectionViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 10
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with category: TradeCategory) {
        titleLabel.text = category.displayName
        iconImageView.image = UIImage(systemName: category.iconName)
    }
}

// MARK: - ServiceProviderCell
class ServiceProviderCell: UITableViewCell {
    private let providerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let businessNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let verifiedBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.seal.fill")
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        accessoryType = .disclosureIndicator
        
        // Set up rating view
        ratingView.addArrangedSubview(starImageView)
        ratingView.addArrangedSubview(ratingLabel)
        
        // Add subviews
        contentView.addSubview(providerImageView)
        contentView.addSubview(businessNameLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(ratingView)
        contentView.addSubview(verifiedBadge)
        
        // Set constraints
        NSLayoutConstraint.activate([
            providerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            providerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            providerImageView.widthAnchor.constraint(equalToConstant: 70),
            providerImageView.heightAnchor.constraint(equalToConstant: 70),
            
            businessNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            businessNameLabel.leadingAnchor.constraint(equalTo: providerImageView.trailingAnchor, constant: 15),
            businessNameLabel.trailingAnchor.constraint(equalTo: verifiedBadge.leadingAnchor, constant: -10),
            
            verifiedBadge.centerYAnchor.constraint(equalTo: businessNameLabel.centerYAnchor),
            verifiedBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 20),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 20),
            
            categoryLabel.topAnchor.constraint(equalTo: businessNameLabel.bottomAnchor, constant: 5),
            categoryLabel.leadingAnchor.constraint(equalTo: businessNameLabel.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 5),
            ratingView.leadingAnchor.constraint(equalTo: businessNameLabel.leadingAnchor),
            
            starImageView.widthAnchor.constraint(equalToConstant: 16),
            starImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(with provider: ServiceProvider) {
        businessNameLabel.text = provider.businessName
        
        // Just join the category strings directly
        let categories = provider.tradeCategories.joined(separator: ", ")
        categoryLabel.text = categories
        
        ratingLabel.text = "\(provider.averageRating) (\(provider.totalReviews))"
        
        // Show verified badge if both insurance and background check are verified
        verifiedBadge.isHidden = !(provider.insuranceVerified && provider.backgroundCheckVerified)
        
        // In a real app, load the profile image from a URL
        providerImageView.image = UIImage(systemName: "person.fill")
    }
}
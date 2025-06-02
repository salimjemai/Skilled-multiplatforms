import UIKit
import StoreKit

class RateAppViewController: UIViewController {
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate SKILLED"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Your feedback helps us improve the app for everyone. Please take a moment to rate your experience."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit Rating", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var starButtons: [UIButton] = []
    private var selectedRating = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Rate App"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starStackView)
        contentView.addSubview(submitButton)
        
        // Create star buttons
        for i in 1...5 {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 40)
            button.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
            button.tintColor = .systemGray
            button.tag = i
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starButtons.append(button)
            starStackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            starStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            starStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            starStackView.heightAnchor.constraint(equalToConstant: 60),
            
            submitButton.topAnchor.constraint(equalTo: starStackView.bottomAnchor, constant: 40),
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        let rating = sender.tag
        selectedRating = rating
        
        // Update star appearances
        for (index, button) in starButtons.enumerated() {
            let config = UIImage.SymbolConfiguration(pointSize: 40)
            if index < rating {
                button.setImage(UIImage(systemName: "star.fill", withConfiguration: config), for: .normal)
                button.tintColor = .systemYellow
            } else {
                button.setImage(UIImage(systemName: "star", withConfiguration: config), for: .normal)
                button.tintColor = .systemGray
            }
        }
    }
    
    @objc private func submitButtonTapped() {
        if selectedRating > 0 {
            // If rating is high (4-5), prompt App Store review
            if selectedRating >= 4 {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            
            // Thank the user
            let alert = UIAlertController(title: "Thank You!", message: "Your feedback helps us improve the app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            // Prompt user to select a rating
            let alert = UIAlertController(title: "Select a Rating", message: "Please select a star rating before submitting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
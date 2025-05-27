import UIKit
import Firebase
import FirebaseAuth

class EmailVerificationViewController: UIViewController {
    
    // MARK: - Properties
    private let email: String
    private var timer: Timer?
    private var verificationChecks = 0
    private let maxVerificationChecks = 30 // Check for 5 minutes (30 * 10 seconds)
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Verify Your Email"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "We've sent a verification email to your address. Please check your inbox and click the verification link."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for verification..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemOrange
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = false
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Resend Verification Email", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue to Login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        emailLabel.text = email
        
        setupUI()
        setupActions()
        startVerificationCheck()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop the timer when the view disappears
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check verification status immediately when the view appears
        // This helps when the user returns to the app after clicking verification link
        checkVerificationStatus()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(instructionLabel)
        containerView.addSubview(emailLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(resendButton)
        containerView.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 16),
            emailLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            activityIndicator.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 24),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            resendButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
            resendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            continueButton.topAnchor.constraint(equalTo: resendButton.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            continueButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupActions() {
        resendButton.addTarget(self, action: #selector(resendVerificationEmail), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueToLogin), for: .touchUpInside)
    }
    
    // MARK: - Verification Methods
    private func startVerificationCheck() {
        // Check every 10 seconds
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(checkVerificationStatus), userInfo: nil, repeats: true)
        timer?.fire() // Check immediately for the first time
    }
    
    @objc private func checkVerificationStatus() {
        verificationChecks += 1
        
        if verificationChecks >= maxVerificationChecks {
            // Stop checking after 5 minutes
            timer?.invalidate()
            timer = nil
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.statusLabel.text = "Verification timeout. You can still login once you verify your email."
                self.statusLabel.textColor = .systemRed
                self.continueButton.isEnabled = true
                self.continueButton.alpha = 1.0
            }
            return
        }
        
        // Reload current user to get latest verification status
        Auth.auth().currentUser?.reload { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error reloading user: \(error.localizedDescription)")
                return
            }
            
            if let isVerified = Auth.auth().currentUser?.isEmailVerified, isVerified {
                // Email is verified
                DispatchQueue.main.async {
                    self.timer?.invalidate()
                    self.timer = nil
                    
                    self.activityIndicator.stopAnimating()
                    self.statusLabel.text = "Email verified successfully! You can now login."
                    self.statusLabel.textColor = .systemGreen
                    self.continueButton.isEnabled = true
                    self.continueButton.alpha = 1.0
                    
                    // Update user record in Firestore
                    if let uid = Auth.auth().currentUser?.uid {
                        Firestore.firestore().collection("users").document(uid).updateData([
                            "isEmailVerified": true
                        ]) { error in
                            if let error = error {
                                print("Error updating verification status: \(error.localizedDescription)")
                            } else {
                                print("Successfully updated email verification status in Firestore")
                                
                                // Cache the verification status
                                UserDefaults.standard.set(true, forKey: "user_\(uid)_emailVerified")
                            }
                        }
                    }
                }
            } else {
                // Update the check count in the UI
                DispatchQueue.main.async {
                    self.statusLabel.text = "Waiting for verification... (Check \(self.verificationChecks)/\(self.maxVerificationChecks))"
                }
            }
        }
    }
    
    @objc private func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to resend verification email: \(error.localizedDescription)")
                } else {
                    self?.showAlert(title: "Success", message: "Verification email sent again. Please check your inbox.")
                    
                    // Reset the timer and counter
                    self?.verificationChecks = 0
                    self?.statusLabel.text = "Waiting for verification... (Check 0/\(self?.maxVerificationChecks ?? 30))"
                }
            }
        }
    }
    
    @objc private func continueToLogin() {
        // Sign out the current user
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        
        // Dismiss all view controllers and return to login
        dismiss(animated: true) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                let loginVC = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginVC)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            } else {
                // Fallback for iOS < 13
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let window = appDelegate.window {
                    let loginVC = LoginViewController()
                    let navigationController = UINavigationController(rootViewController: loginVC)
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

import UIKit
import Firebase
import FirebaseAuth
import SystemConfiguration
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseCore

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hammer.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Skilled"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect with skilled professionals"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupActions()
        
        // Test Firebase Auth initialization
        #if DEBUG
        print("LoginViewController: Starting Firebase Auth diagnostics...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.testFirebaseAuth()
        }
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Log screen view event for Firebase Analytics
        logScreenView(screenName: "Login", screenClass: "LoginViewController")
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(registerPromptLabel)
        view.addSubview(registerButton)
        view.addSubview(activityIndicator)
        
        // Set constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            registerPromptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registerPromptLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            
            registerButton.leadingAnchor.constraint(equalTo: registerPromptLabel.trailingAnchor, constant: 5),
            registerButton.centerYAnchor.constraint(equalTo: registerPromptLabel.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Action Methods
    @objc private func loginButtonTapped() {
        guard let emailInput = emailTextField.text, !emailInput.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password")
            return
        }
        
        // Normalize email to lowercase
        let email = emailInput.lowercased()
        
        // Check for network connectivity
        if !isNetworkReachable() {
            showAlert(title: "Network Error", message: "Please check your internet connection and try again.")
            return
        }
        
        // Show activity indicator
        activityIndicator.startAnimating()
        loginButton.isEnabled = false
        
        // Store the email for future convenience
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(email, forKey: "lastLoginEmail")
        
        // First check if the email exists in Firestore
        checkEmailExists(email: email) { [weak self] exists in
            guard let self = self else { return }
            
            if !exists {
                // Email doesn't exist in our database
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.isEnabled = true
                    
                    self.showAlert(
                        title: "Account Not Found",
                        message: "No account found with this email address. Would you like to create a new account?",
                        actions: [
                            UIAlertAction(title: "Sign Up", style: .default) { _ in
                                self.registerButtonTapped()
                            },
                            UIAlertAction(title: "Try Again", style: .cancel)
                        ]
                    )
                    
                    // Log the failure
                    self.logLoginFailure(error: "No account found with this email")
                }
                return
            }
            
            // Email exists, proceed with authentication
            self.authenticateUser(email: email, password: password)
        }
    }
    
    private func checkEmailExists(email: String, completion: @escaping (Bool) -> Void) {
        // Ensure email is lowercase for consistent checking
        let normalizedEmail = email.lowercased()
        print("Checking if email exists: \(normalizedEmail)")
        
        // Check directly in Firestore now that it's enabled
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: normalizedEmail)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking email in Firestore: \(error.localizedDescription)")
                    // Log the error for analytics
                    Analytics.logEvent("firestore_error", parameters: [
                        "operation": "check_email",
                        "error_message": error.localizedDescription.prefix(100),
                        "email_hash": String(email.hashValue)
                    ])
                    // Fall back to Firebase Auth if Firestore fails
                    self.checkEmailWithAuth(email: email, completion: completion)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    print("Firestore email check result: true")
                    completion(true)
                } else {
                    print("Firestore email check result: false, double-checking with Auth")
                    // Double-check with Auth as fallback
                    self.checkEmailWithAuth(email: email, completion: completion)
                }
            }
    }
    
    private func checkEmailWithAuth(email: String, completion: @escaping (Bool) -> Void) {
        // Ensure email is lowercase for consistent checking
        let normalizedEmail = email.lowercased()
        
        // Use fetchSignInMethods which is the proper way to check if an email exists
        Auth.auth().fetchSignInMethods(forEmail: normalizedEmail) { methods, error in
            if let error = error {
                print("Error checking email with Auth: \(error.localizedDescription)")
                
                // Check for specific network errors
                let nsError = error as NSError
                if nsError.domain == AuthErrorDomain && 
                   (nsError.code == AuthErrorCode.networkError.rawValue || 
                    nsError.code == AuthErrorCode.tooManyRequests.rawValue) {
                    // For network errors, report that the email might exist to avoid false negatives
                    // This prevents showing "No account found" error when it could be a network issue
                    print("Network error during Auth check, assuming email might exist")
                    completion(true)
                } else {
                    // For other errors, check if it's specifically about the email not existing
                    if nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.userNotFound.rawValue {
                        completion(false)
                    } else {
                        // For unknown errors, default to assuming the email might exist
                        // This is safer than incorrectly telling a user their account doesn't exist
                        completion(true)
                    }
                }
                return
            }
            
            if let methods = methods, !methods.isEmpty {
                print("Auth check: Email exists with methods: \(methods)")
                completion(true)
            } else {
                print("Auth check: Email doesn't exist")
                completion(false)
            }
        }
    }
    
    private func authenticateUser(email: String, password: String) {
        // Ensure email is lowercase for consistent authentication
        let normalizedEmail = email.lowercased()
        
        Auth.auth().signIn(withEmail: normalizedEmail, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            // Hide activity indicator
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loginButton.isEnabled = true
            }
            
            if let error = error {
                // Handle specific Firebase auth errors
                let errorCode = (error as NSError).code
                var errorMessage = error.localizedDescription
                
                switch errorCode {
                case AuthErrorCode.networkError.rawValue:
                    errorMessage = "Network error occurred. Please check your internet connection."
                case AuthErrorCode.userNotFound.rawValue:
                    errorMessage = "No account found with this email. Please check your email or sign up."
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Incorrect password. Please try again."
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "Invalid email format. Please enter a valid email."
                case AuthErrorCode.userDisabled.rawValue:
                    errorMessage = "This account has been disabled. Please contact support."
                case AuthErrorCode.tooManyRequests.rawValue:
                    errorMessage = "Too many unsuccessful login attempts. Please try again later."
                default:
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
                
                DispatchQueue.main.async {
                    self.showAlert(title: "Login Failed", message: errorMessage)
                }
                
                // Log login failure
                self.logLoginFailure(error: errorMessage)
                return
            }
            
            // Check if email is verified before proceeding
            guard let user = Auth.auth().currentUser else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to get user information")
                }
                return
            }
            
            // Check email verification status
            user.reload { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Failed to refresh user information: \(error.localizedDescription)")
                    }
                    return
                }
                
                // Check cached verification status first (for quicker response)
                let cachedVerificationStatus = UserDefaults.standard.bool(forKey: "user_\(user.uid)_emailVerified")
                
                if cachedVerificationStatus || user.isEmailVerified {
                    // Email is verified (either cached or from server), proceed with login
                    DispatchQueue.main.async {
                        // Update cache if needed
                        if !cachedVerificationStatus && user.isEmailVerified {
                            UserDefaults.standard.set(true, forKey: "user_\(user.uid)_emailVerified")
                        }
                        // Log login success
                        self.logLoginSuccess()
                        self.loginSuccessful()
                    }
                } else {
                    // Email not verified, show verification screen
                    DispatchQueue.main.async {
                        self.showAlert(
                            title: "Email Not Verified", 
                            message: "Your email is not verified. Please check your inbox for a verification link or request a new verification email.",
                            actions: [
                                UIAlertAction(title: "Resend Email", style: .default) { _ in
                                    self.resendVerificationEmail(to: user.email ?? "")
                                },
                                UIAlertAction(title: "Cancel", style: .cancel)
                            ]
                        )
                    }
                }
            }
        }
    }
    
    @objc private func forgotPasswordButtonTapped() {
        let alertController = UIAlertController(title: "Reset Password", 
                                              message: "Enter your email address", 
                                              preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] _ in
            guard let email = alertController.textFields?.first?.text, !email.isEmpty else {
                self?.showAlert(title: "Error", message: "Please enter your email address")
                return
            }
            
            // Show loading indicator
            self?.activityIndicator.startAnimating()
            
            // Send password reset email
            Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    
                    if let error = error {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self?.showAlert(title: "Password Reset", message: "A password reset link has been sent to your email.")
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(resetAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loginSuccessful() {
        // Create a tab bar controller for the main app interface
        let tabBarController = UITabBarController()
        
        // Home tab
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Search tab
        let searchVC = ServiceListViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        // Bookings tab
        let bookingsVC = BookingsViewController()
        let bookingsNav = UINavigationController(rootViewController: bookingsVC)
        bookingsNav.tabBarItem = UITabBarItem(title: "Bookings", image: UIImage(systemName: "calendar"), tag: 2)
        
        // Profile tab
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        // Set up tab bar
        tabBarController.viewControllers = [homeNav, searchNav, bookingsNav, profileNav]
        tabBarController.modalPresentationStyle = .fullScreen
        
        // Present the tab bar controller
        present(tabBarController, animated: true, completion: nil)
    }
    
    // MARK: - Email Verification
    private func showEmailVerificationScreen(email: String) {
        // Create an alert with information instead of showing the full screen
        let alertController = UIAlertController(
            title: "Email Verification Required",
            message: "Please check your inbox at \(email) for a verification link. You need to verify your email before you can log in.",
            preferredStyle: .alert
        )
        
        // Add resend action
        alertController.addAction(UIAlertAction(title: "Resend Verification", style: .default) { [weak self] _ in 
            self?.resendVerificationEmail(to: email)
        })
        
        // Add cancel action
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        // Present the alert
        present(alertController, animated: true)
    }
    
    private func resendVerificationEmail(to email: String) {
        activityIndicator.startAnimating()
        
        // User needs to be signed in to send verification email
        Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to send verification email: \(error.localizedDescription)")
                } else {
                    self?.showAlert(title: "Email Sent", message: "Verification email has been sent to \(email). Please check your inbox and verify your email.")
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
    
    private func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alert.addAction(action)
        }
        present(alert, animated: true)
    }
    
    // MARK: - Network Utility Methods
    private func isNetworkReachable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    // MARK: - Analytics
    private func logScreenView(screenName: String, screenClass: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
    
    private func logLoginSuccess() {
        Analytics.logEvent("login_success", parameters: nil)
    }
    
    private func logLoginFailure(error: String) {
        // Limit error message length to 100 characters to avoid Firebase Analytics parameter limit
        let truncatedError = error.count > 100 ? String(error.prefix(97)) + "..." : error
        
        Analytics.logEvent("login_failure", parameters: [
            "error_code": getErrorCode(from: error),
            "error_type": getErrorType(from: error),
            "error_message": truncatedError
        ])
    }
    
    // Helper method to extract error code from error message
    private func getErrorCode(from errorMessage: String) -> String {
        // Common Firebase Auth error codes
        if errorMessage.contains("network error") { return "network_error" }
        if errorMessage.contains("wrong password") { return "wrong_password" }
        if errorMessage.contains("user not found") { return "user_not_found" }
        if errorMessage.contains("invalid email") { return "invalid_email" }
        if errorMessage.contains("email already in use") { return "email_in_use" }
        if errorMessage.contains("too many requests") { return "too_many_requests" }
        if errorMessage.contains("disabled") { return "account_disabled" }
        if errorMessage.contains("verification") { return "not_verified" }
        return "unknown_error"
    }
    
    // Helper method to categorize error type
    private func getErrorType(from errorMessage: String) -> String {
        if errorMessage.contains("network") { return "connectivity" }
        if errorMessage.contains("password") { return "authentication" }
        if errorMessage.contains("user not found") { return "account" }
        if errorMessage.contains("email") { return "validation" }
        if errorMessage.contains("verification") { return "verification" }
        if errorMessage.contains("disabled") { return "account" }
        if errorMessage.contains("too many") { return "rate_limit" }
        return "general"
    }
    
    // MARK: - Firebase Auth Testing
    private func testFirebaseAuth() {
        print("Firebase Diagnostics: Testing Firebase Auth initialization...")
        
        // Check if Firebase is configured
        if FirebaseApp.app() == nil {
            print("Firebase Diagnostics: ERROR - Firebase App not initialized!")
            
            // Attempt to configure
            do {
                FirebaseApp.configure()
                print("Firebase Diagnostics: Firebase configured successfully")
            } catch let error {
                print("Firebase Diagnostics: Failed to configure Firebase: \(error.localizedDescription)")
                return
            }
        } else {
            print("Firebase Diagnostics: Firebase App is initialized")
        }
        
        // Check Auth instance
        let auth = Auth.auth()
        print("Firebase Diagnostics: Auth instance exists: \(auth)")
        
        // Test a basic Auth operation
        auth.useAppLanguage()
        print("Firebase Diagnostics: Firebase Auth language set")
        
        // Get current user (will be nil if not signed in)
        if let user = auth.currentUser {
            print("Firebase Diagnostics: Current user exists: \(user.uid)")
        } else {
            print("Firebase Diagnostics: No current user")
        }
        
        // Check bundle ID
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            print("Firebase Diagnostics: App bundle ID: \(bundleIdentifier)")
        } else {
            print("Firebase Diagnostics: ERROR - No bundle identifier!")
        }
        
        // Check for GoogleService-Info.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("Firebase Diagnostics: GoogleService-Info.plist found at: \(path)")
            
            // Read the bundle ID from the plist
            if let plistDict = NSDictionary(contentsOfFile: path),
               let plistBundleID = plistDict["BUNDLE_ID"] as? String {
                print("Firebase Diagnostics: Plist bundle ID: \(plistBundleID)")
                
                // Compare with app's bundle ID
                if let appBundleID = Bundle.main.bundleIdentifier {
                    if plistBundleID == appBundleID {
                        print("Firebase Diagnostics: ✅ Bundle IDs match!")
                    } else {
                        print("Firebase Diagnostics: ❌ Bundle ID mismatch! App: \(appBundleID), Plist: \(plistBundleID)")
                    }
                }
            } else {
                print("Firebase Diagnostics: ERROR - Couldn't read BUNDLE_ID from plist")
            }
        } else {
            print("Firebase Diagnostics: ❌ ERROR - GoogleService-Info.plist not found in the app bundle!")
        }
        
        // Test if Auth can be used
        print("Firebase Diagnostics: Testing anonymous auth existence...")
        let settings = auth.settings
        print("Firebase Diagnostics: Auth settings available: \(settings)")
        
        print("Firebase Diagnostics: Tests completed")
        
        //Display results in UI for visibility
        // Diagnostic prompt disabled
        // DispatchQueue.main.async {
        //     self.showFirebaseDiagnosticResults()
        // }
    }
    
    private func showFirebaseDiagnosticResults() {
        // Function disabled - no longer showing diagnostic prompt
        // This function is kept for reference but will not be called
    }
}

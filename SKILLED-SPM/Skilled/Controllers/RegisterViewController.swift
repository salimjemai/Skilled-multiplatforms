import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics // Make sure Firebase Analytics is properly imported
import Foundation  // Required for Date
import AuthenticationServices
import CryptoKit

// Import local models
// If User.swift is in the same module (app target), no extra import is needed

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    // Direct reference to Firestore database
    private let db = Firestore.firestore()
    
    // Apple Sign-In state
    private var currentNonce: String?
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Your Account"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // Social sign-in buttons
    private let socialButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue with Apple", for: .normal)
        button.setImage(UIImage(systemName: "apple.logo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(registerButton)
        view.addSubview(activityIndicator)
        view.addSubview(socialButtonsStackView)
        view.addSubview(dividerView)
        view.addSubview(orLabel)
        
        // Add social sign-in buttons to stack view
        socialButtonsStackView.addArrangedSubview(appleSignInButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 15),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            
            // Constraints for social sign-in UI components
            socialButtonsStackView.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 40),
            socialButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            socialButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dividerView.topAnchor.constraint(equalTo: socialButtonsStackView.bottomAnchor, constant: 20),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            orLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 10),
            orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        // Add target actions for social sign-in buttons
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func registerButtonTapped() {
        // Validate inputs
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        // Make sure Firebase is initialized
        ensureFirebaseIsInitialized()
        
        // Show activity indicator
        activityIndicator.startAnimating()
        registerButton.isEnabled = false
        
        // Check if email already exists
        checkEmailExists(email) { [weak self] exists in
            guard let self = self else { return }
            
            // Hide activity indicator
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.registerButton.isEnabled = true
            }
            
            if exists {
                // Email already exists, show error
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Email is already in use")
                }
                return
            }
            
            // Create user with Firebase Auth
            print("Attempting to create user with email: \(email)")
            // Add a delay before creating user to give Firebase Auth time to initialize fully
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                    guard let self = self else { return }
                    
                    // Hide activity indicator
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.registerButton.isEnabled = true
                    }
                    
                    if let error = error {
                        // Handle specific Firebase auth errors
                        let nsError = error as NSError
                        print("Firebase Auth Error: Code=\(nsError.code), Domain=\(nsError.domain), Description=\(error.localizedDescription)")
                        
                        if let errorInfo = nsError.userInfo[NSDebugDescriptionErrorKey] as? String {
                            print("Error Debug Info: \(errorInfo)")
                        }
                        
                        // Use the raw value directly instead of trying to create an AuthErrorCode
                        let errorCode = nsError.code
                        var errorMessage = error.localizedDescription
                        
                        print("Firebase Auth Error Code: \(errorCode)")
                        
                        // Check against known error code values
                        switch errorCode {
                        case 17020: // .networkError
                            errorMessage = "Network error occurred. Please check your internet connection."
                        case 17008: // .invalidEmail
                            errorMessage = "The email address is invalid. Please enter a valid email."
                        case 17007: // .emailAlreadyInUse
                            errorMessage = "The email address is already in use by another account."
                        case 17026: // .weakPassword
                            errorMessage = "Your password is too weak. Please choose a stronger password."
                        case 17010: // .tooManyRequests
                            errorMessage = "Too many requests. Please try again later."
                        case 17999: // .internalError
                            errorMessage = "An internal error occurred. Try again in a few moments. If this persists, check your internet connection and try rebooting the app."
                            print("*** SPECIAL HANDLING FOR INTERNAL ERROR CODE 17999 ***")
                            // Dump all error info for debugging
                            print("Full NSError details for 17999:")
                            print("Domain: \(nsError.domain)")
                            print("Code: \(nsError.code)")
                            print("Description: \(nsError.localizedDescription)")
                            print("User Info: \(nsError.userInfo)")
                            
                            // Check for specific configuration errors
                            if let errorDetails = nsError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
                               let message = errorDetails["message"] as? String {
                                print("Firebase Auth internal error message: \(message)")
                                
                                if message.contains("CONFIGURATION_NOT_FOUND") {
                                    // This is specifically a configuration mismatch issue
                                    errorMessage = "App configuration error. The app's identifier doesn't match Firebase settings. Please update the app."
                                    
                                    // Try to fix the issue
                                    DispatchQueue.main.async {
                                        // Check if the GoogleService-Info.plist bundle ID matches the app's bundle ID
                                        self.checkBundleIdMatch { matches in
                                            if !matches {
                                                // Show a more specific error if bundle IDs don't match
                                                self.showAlert(title: "Configuration Error",
                                                               message: "The app's bundle identifier doesn't match Firebase settings. Please contact support.")
                                            }
                                        }
                                    }
                                }
                            }
                        default:
                            errorMessage = "Registration failed: \(error.localizedDescription)"
                        }
                        
                        DispatchQueue.main.async {
                            self.showAlert(title: "Registration Failed", message: errorMessage)
                            self.logRegistrationFailure(error: "Auth error: \(errorMessage)")
                        }
                        return
                    }
                    
                    // Registration successful, create user profile
                    guard let uid = result?.user.uid else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Failed to create user profile")
                        }
                        return
                    }
                    
                    // Update display name
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = name
                    changeRequest?.commitChanges { [weak self] error in
                        if let error = error {
                            print("Error updating user profile: \(error.localizedDescription)")
                        }
                    }
                    
                    // Send email verification
                    result?.user.sendEmailVerification { [weak self] error in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                self?.showAlert(
                                    title: "Warning",
                                    message: "Account created but we couldn't send a verification email. You can request another one after logging in.",
                                    completion: { _ in
                                        // Go back to login screen even if verification email failed
                                        self?.navigationController?.popViewController(animated: true)
                                    }
                                )
                            }
                        } else {
                            print("Verification email sent successfully")
                            
                            // The success path is handled below in the Firestore callback
                        }
                    }
                    
                    // Create a proper User object using our model
                    let nameParts = name.components(separatedBy: " ")
                    let firstName = nameParts.first ?? ""
                    let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
                    
                    // Create current date - let Firestore handle timestamp conversion
                    let currentDate = Date()
                    
                    let newUser = User(
                        id: uid,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phoneNumber: nil,
                        profileImageUrl: nil,
                        role: .customer, // Using .customer shorthand for clarity
                        location: nil,
                        isVerified: false,
                        createdAt: currentDate,
                        updatedAt: currentDate
                    )
                    
                    // Save user using Firestore directly
                    let db = Firestore.firestore()
                    let userData = newUser.toDictionary()
                    
                    // Add better error handling for Firestore
                    print("Attempting to save user to Firestore: \(newUser.id)")
                    print("User data for Firestore: \(userData)")
                    
                    db.collection("users").document(newUser.id).setData(userData) { [weak self] error in
                        if let error = error {
                            print("Error saving user to Firestore: \(error.localizedDescription)")
                            if let fireError = error as NSError? {
                                print("Firestore Error Details: Code=\(fireError.code), Domain=\(fireError.domain)")
                                if let errorInfo = fireError.userInfo[NSDebugDescriptionErrorKey] as? String {
                                    print("Firestore Error Debug Info: \(errorInfo)")
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self?.showAlert(title: "Error", message: "Account created but failed to save profile: \(error.localizedDescription)")
                                self?.logRegistrationFailure(error: "Firestore save error: \(error.localizedDescription)")
                            }
                        } else {
                            print("User successfully saved to Firestore with ID: \(newUser.id)")
                            
                            DispatchQueue.main.async {
                                self?.logRegistrationSuccess()
                                // Show verification screen instead of just returning to login
                                self?.showEmailVerificationScreen(email: email)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Email Verification
    // Check if email already exists in Firestore
    private func checkEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        print("Checking if email exists before registration: \(email)")
        
        // Check directly in Firestore
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking email in Firestore: \(error.localizedDescription)")
                    if let fireError = error as NSError? {
                        print("Firestore Error Details: Code=\(fireError.code), Domain=\(fireError.domain)")
                    }
                    // Skip the problematic Auth check and assume email doesn't exist to allow registration
                    print("Firestore email check failed, skipping Auth check and proceeding with registration")
                    completion(false)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    print("Firestore email check result: true (email exists)")
                    completion(true)
                } else {
                    print("Firestore email check result: false (email doesn't exist), proceeding with registration")
                    // Skip Auth check because it's failing with internal error
                    // Go directly to registration
                    completion(false)
                }
            }
    }
    
    private func checkEmailWithAuth(email: String, completion: @escaping (Bool) -> Void) {
        // Use the modern approach to check if email exists
        // We're using the newer error-based approach instead of fetchSignInMethods
        Auth.auth().signIn(withEmail: email, password: "temp_password_for_check") { _, error in
            // Check error to determine if account exists
            if let error = error as NSError? {
                print("Firebase Auth Check Email Error: Code=\(error.code), Domain=\(error.domain), Description=\(error.localizedDescription)")
                
                // Use the raw error code directly
                let errorCode = error.code
                
                if errorCode == 17009 { // .wrongPassword
                    // Wrong password means the account exists
                    print("Auth check: Email exists (wrong password)")
                    completion(true)
                } else if errorCode == 17011 { // .userNotFound
                    // User not found means email doesn't exist
                    print("Auth check: Email doesn't exist (user not found)")
                    completion(false)
                } else if errorCode == 17008 { // .invalidEmail
                    // Invalid email format
                    print("Auth check: Invalid email format")
                    completion(false)
                } else if errorCode == 17020 || errorCode == 17010 { // .networkError or .tooManyRequests
                    // For network errors, default to assuming email doesn't exist to allow registration to continue
                    print("Auth check: Network error, assuming email doesn't exist to continue registration")
                    completion(false)
                } else if errorCode == 17999 { // .internalError
                    // For internal errors, assume email doesn't exist to allow registration attempt
                    print("Auth check: Internal error (\(error.code)), assuming email doesn't exist")
                    if let errorInfo = error.userInfo[NSDebugDescriptionErrorKey] as? String {
                        print("Error Debug Info: \(errorInfo)")
                    }
                    completion(false)
                } else {
                    // For other errors, log additional info and assume email doesn't exist
                    print("Auth check: Other error (Code: \(errorCode)), assuming email doesn't exist")
                    if let errorInfo = error.userInfo[NSDebugDescriptionErrorKey] as? String {
                        print("Error Debug Info: \(errorInfo)")
                    }
                    completion(false)
                }
            } else {
                // This should not happen (successful login with incorrect password)
                print("Auth check: Unexpected successful login")
                completion(true)
            }
        }
    }
    
    private func showEmailVerificationScreen(email: String) {
        // Create alert controller with verification information
        let alertController = UIAlertController(
            title: "Verify Your Email",
            message: "We've sent a verification email to \(email). Please check your inbox and click the verification link before logging in.",
            preferredStyle: .alert
        )
        
        // Add option to resend verification email
        alertController.addAction(UIAlertAction(title: "Resend Email", style: .default) { [weak self] _ in
            // Resend verification email
            Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: "Failed to resend verification email: \(error.localizedDescription)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert(
                            title: "Email Sent",
                            message: "Verification email has been sent again to \(email).",
                            completion: { _ in
                                // Return to login screen
                                self?.navigationController?.popViewController(animated: true)
                            }
                        )
                    }
                }
            }
        })
        
        // Add option to continue to login
        alertController.addAction(UIAlertAction(title: "Continue to Login", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        // Present the alert
        present(alertController, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    // MARK: - Analytics Logging
    private func logRegistrationSuccess() {
        // Log successful registration with additional parameters
        Analytics.logEvent("registration_success", parameters: [
            "method": "email_password",
            "user_type": "customer",
            "has_profile_image": false
        ])
        
        // Also log a standard sign_up event that Firebase will recognize
        Analytics.logEvent("sign_up", parameters: [
            "method": "email_password"
        ])
    }
    
    private func logRegistrationSuccess(method: String) {
        // Log successful registration with additional parameters
        Analytics.logEvent("registration_success", parameters: [
            "method": method,
            "user_type": "customer",
            "has_profile_image": method != "email_password"
        ])
        
        // Also log a standard sign_up event that Firebase will recognize
        Analytics.logEvent("sign_up", parameters: [
            "method": method
        ])
    }
    
    private func logRegistrationFailure(error: String) {
        // Limit error message length to 100 characters to avoid Firebase Analytics parameter limit
        let truncatedError = error.count > 100 ? String(error.prefix(97)) + "..." : error
        let errorCode = getErrorCode(from: error)
        let errorType = getErrorType(from: error)
        
        // Log detailed registration failure
        Analytics.logEvent("registration_failure", parameters: [
            "error_code": errorCode,
            "error_type": errorType,
            "error_message": truncatedError,
            "method": "email_password"
        ])
    }
    
    // Helper method to extract error code from error message
    private func getErrorCode(from errorMessage: String) -> String {
        // Common Firebase Auth error codes
        if errorMessage.contains("network error") { return "network_error" }
        if errorMessage.contains("password") { return "password_error" }
        if errorMessage.contains("user not found") { return "user_not_found" }
        if errorMessage.contains("invalid email") { return "invalid_email" }
        if errorMessage.contains("email already in use") { return "email_in_use" }
        if errorMessage.contains("too many requests") { return "too_many_requests" }
        if errorMessage.contains("disabled") { return "account_disabled" }
        if errorMessage.contains("verification") { return "verification_error" }
        if errorMessage.contains("Firestore") { return "firestore_error" }
        return "unknown_error"
    }
    
    // Helper method to categorize error type
    private func getErrorType(from errorMessage: String) -> String {
        if errorMessage.contains("network") { return "connectivity" }
        if errorMessage.contains("password") { return "validation" }
        if errorMessage.contains("email") { return "validation" }
        if errorMessage.contains("verification") { return "verification" }
        if errorMessage.contains("Firestore") { return "database" }
        if errorMessage.contains("disabled") { return "account" }
        if errorMessage.contains("too many") { return "rate_limit" }
        return "general"
    }
    
    // MARK: - Firebase Initialization
    private func ensureFirebaseIsInitialized() {
        if FirebaseApp.app() == nil {
            print("RegisterVC: Firebase not initialized. Initializing now...")
            
            // Check if GoogleService-Info.plist exists
            if let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
                // Add a small delay to ensure proper initialization
                Thread.sleep(forTimeInterval: 0.3)
                FirebaseApp.configure()
                print("RegisterVC: Firebase initialized successfully")
            } else {
                print("RegisterVC: ERROR - GoogleService-Info.plist not found!")
                showAlert(title: "Configuration Error", message: "The app is missing required configuration files. Please contact support.")
            }
        } else {
            print("RegisterVC: Firebase already initialized")
        }
    }
    
    // Check if the bundle ID in GoogleService-Info.plist matches the app's bundle ID
    private func checkBundleIdMatch(completion: @escaping (Bool) -> Void) {
        // Get the app's bundle ID
        guard let appBundleID = Bundle.main.bundleIdentifier else {
            print("RegisterVC: Could not get app bundle ID")
            completion(false)
            return
        }
        
        // Get the bundle ID from GoogleService-Info.plist
        guard let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let firebaseBundleID = plistDict["BUNDLE_ID"] as? String else {
            print("RegisterVC: Could not read bundle ID from GoogleService-Info.plist")
            completion(false)
            return
        }
        
        // Compare the bundle IDs
        let matches = appBundleID == firebaseBundleID
        print("RegisterVC: Bundle ID check - App: \(appBundleID), Firebase: \(firebaseBundleID), Match: \(matches)")
        completion(matches)
    }
    
    // MARK: - Social Sign-In Methods
    
    @objc private func appleSignInTapped() {
        print("Apple Sign-In tapped")
        
        // Ensure Firebase is initialized
        ensureFirebaseIsInitialized()
        
        // Show activity indicator
        activityIndicator.startAnimating()
        
        // Generate a random nonce for Sign in with Apple
        let nonce = generateNonce()
        currentNonce = nonce
        
        // Set up Apple Sign-In request
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        // Set up the Apple Sign-In controller
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // SHA256 function for Apple Sign-In
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func authenticateWithFirebase(credential: AuthCredential, provider: String) {
        // Show activity indicator
        activityIndicator.startAnimating()
        
        // Sign in to Firebase with the credential
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            // Hide activity indicator
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                print("\(provider.capitalized) authentication error: \(error.localizedDescription)")
                self.showAlert(title: "Authentication Failed", message: "Failed to authenticate with \(provider.capitalized): \(error.localizedDescription)")
                self.logRegistrationFailure(error: "\(provider) authentication error: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                print("Error: User is nil after \(provider) authentication")
                self.showAlert(title: "Authentication Failed", message: "Failed to get user data from \(provider.capitalized)")
                return
            }
            
            // Check if this is a new user
            if authResult?.additionalUserInfo?.isNewUser == true {
                // Create and save user profile in Firestore
                self.createUserProfileInFirestore(user: user, provider: provider)
            } else {
                // User already exists, just log the success and navigate
                self.logRegistrationSuccess(method: provider)
                // Navigate to the main app
                DispatchQueue.main.async {
                    // Show welcome message
                    self.showAlert(
                        title: "Welcome Back",
                        message: "You've successfully signed in with \(provider.capitalized).",
                        completion: { _ in
                            // Navigate to the main screen or dashboard
                            // This depends on your app's navigation flow
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                }
            }
        }
    }
    
    // Create a user profile in Firestore after social authentication
    private func createUserProfileInFirestore(user: FirebaseAuth.User, provider: String) {
        // Extract name components - default to email if no display name
        let displayName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? ""
        let nameParts = displayName.components(separatedBy: " ")
        let firstName = nameParts.first ?? ""
        let lastName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
        
        // Create current date
        let currentDate = Date()
        
        // Create a User object
        let newUser = User(
            id: user.uid,
            firstName: firstName,
            lastName: lastName,
            email: user.email ?? "",
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.photoURL?.absoluteString,
            role: .customer,
            location: nil,
            isVerified: user.isEmailVerified,
            createdAt: currentDate,
            updatedAt: currentDate
        )
        
        // Save user to Firestore
        let userData = newUser.toDictionary()
        
        db.collection("users").document(newUser.id).setData(userData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error saving user to Firestore: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: "Account created but failed to save profile: \(error.localizedDescription)")
                self.logRegistrationFailure(error: "Firestore save error after \(provider) auth: \(error.localizedDescription)")
            } else {
                print("User successfully saved to Firestore with ID: \(newUser.id)")
                
                // Log success
                self.logRegistrationSuccess(method: provider)
                
                // Show welcome message and navigate
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "Account Created",
                        message: "Welcome to the app! Your account has been created successfully using \(provider.capitalized) Sign-In.",
                        completion: { _ in
                            // Navigate to the main screen or dashboard
                            // This depends on your app's navigation flow
                            self.navigationController?.popViewController(animated: true)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension RegisterViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Hide activity indicator
        activityIndicator.stopAnimating()
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Error: Unable to get identity token or nonce")
                showAlert(title: "Sign-In Failed", message: "Failed to authenticate with Apple")
                return
            }
            
            // Create an Apple credential for Firebase
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                     idToken: idTokenString,
                                                     rawNonce: nonce)
            
            // Store user information from Apple ID credential
            if let fullName = appleIDCredential.fullName {
                // Save the user's name in UserDefaults for later use
                UserDefaults.standard.set(fullName.givenName, forKey: "appleSignInFirstName")
                UserDefaults.standard.set(fullName.familyName, forKey: "appleSignInLastName")
            }
            
            // Authenticate with Firebase
            authenticateWithFirebase(credential: credential, provider: "apple")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Hide activity indicator
        activityIndicator.stopAnimating()
        
        print("Apple Sign-In error: \(error.localizedDescription)")
        showAlert(title: "Sign-In Failed", message: "Failed to sign in with Apple: \(error.localizedDescription)")
        logRegistrationFailure(error: "Apple sign-in error: \(error.localizedDescription)")
    }
    
    // Generate a random nonce for Apple Sign-In
    private func randomNonceString(length: Int = 32) -> String {
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            for random in randoms {
                if remainingLength == 0 {
                    break
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Helper method to generate and store a nonce
    private func generateNonce() -> String {
        let nonce = randomNonceString()
        UserDefaults.standard.set(nonce, forKey: "appleSignInNonce")
        return nonce
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

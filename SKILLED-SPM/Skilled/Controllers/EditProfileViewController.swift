import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import MapKit

class EditProfileViewController: UIViewController {
    
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
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 50
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let roleSegmentedControl: UISegmentedControl = {
        let items = ["Client", "Service Provider"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // Service type selection UI
    let serviceTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let serviceTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Update Service Types:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let serviceTypeOptions: [String] = [
        "Plumbing", "Electrical", "Carpentry", "Cleaning", 
        "Painting", "Landscaping", "Moving", "Handyman",
        "HVAC", "Roofing", "Flooring", "Appliance Repair",
        "Pest Control", "Window Cleaning", "Pool Service", "Other"
    ]
    var serviceTypeCheckboxes: [UIButton] = []
    var selectedServices: [String] = []
    
    private let addressLine1TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Address Line 1"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let addressLine2TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Address Line 2 (Optional)"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let cityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "City"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let stateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "State"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let zipCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ZIP Code"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemBlue
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
    var user: User?
    private var selectedImage: UIImage?
    private let addressValidator = AddressValidationService()
    private var isAddressValid = false
    private var validationTimer: Timer?
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    private var resultsTableView: UITableView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        populateFields()
        
        // Add action to role segmented control
        roleSegmentedControl.addTarget(self, action: #selector(roleChanged(_:)), for: .valueChanged)
        
        // Check if we need to highlight address fields
        if let addressRequired = navigationItem.rightBarButtonItem?.title, addressRequired == "Address Required" {
            highlightAddressFields()
        }
    }
    
    private func highlightAddressFields() {
        // Add a label to indicate required fields
        let requiredLabel = UILabel()
        requiredLabel.text = "Please complete your address information"
        requiredLabel.textColor = .systemRed
        requiredLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        requiredLabel.textAlignment = .center
        requiredLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(requiredLabel)
        
        NSLayoutConstraint.activate([
            requiredLabel.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 5),
            requiredLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            requiredLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Highlight address fields
        addressLine1TextField.layer.borderColor = UIColor.systemRed.cgColor
        addressLine1TextField.layer.borderWidth = 1
        cityTextField.layer.borderColor = UIColor.systemRed.cgColor
        cityTextField.layer.borderWidth = 1
        stateTextField.layer.borderColor = UIColor.systemRed.cgColor
        stateTextField.layer.borderWidth = 1
        zipCodeTextField.layer.borderColor = UIColor.systemRed.cgColor
        zipCodeTextField.layer.borderWidth = 1
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update suggestion table position if needed
        if let tableView = resultsTableView {
            let addressFieldFrame = addressLine1TextField.convert(addressLine1TextField.bounds, to: view)
            tableView.frame = CGRect(
                x: addressFieldFrame.minX,
                y: addressFieldFrame.maxY + 5,
                width: addressFieldFrame.width,
                height: 200
            )
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(lastNameTextField)
        contentView.addSubview(roleSegmentedControl)
        contentView.addSubview(serviceTypeStackView)
        serviceTypeStackView.addArrangedSubview(serviceTypeLabel)
        
        // Create checkboxes for each service type
        for serviceType in serviceTypeOptions {
            let button = UIButton(type: .system)
            button.setTitle("□ \(serviceType)", for: .normal)
            button.setTitle("✓ \(serviceType)", for: .selected)
            button.contentHorizontalAlignment = .left
            button.addTarget(self, action: #selector(serviceTypeToggled(_:)), for: .touchUpInside)
            serviceTypeStackView.addArrangedSubview(button)
            serviceTypeCheckboxes.append(button)
        }
        
        contentView.addSubview(addressLine1TextField)
        contentView.addSubview(addressLine2TextField)
        contentView.addSubview(cityTextField)
        contentView.addSubview(stateTextField)
        contentView.addSubview(zipCodeTextField)
        contentView.addSubview(saveButton)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            firstNameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 20),
            firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 10),
            lastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Role segmented control is hidden but keep constraints
            roleSegmentedControl.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            roleSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            roleSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            roleSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            // Service type stack after address fields
            serviceTypeStackView.topAnchor.constraint(equalTo: zipCodeTextField.bottomAnchor, constant: 20),
            serviceTypeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            serviceTypeStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addressLine1TextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            addressLine1TextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLine1TextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addressLine1TextField.heightAnchor.constraint(equalToConstant: 44),
            
            addressLine2TextField.topAnchor.constraint(equalTo: addressLine1TextField.bottomAnchor, constant: 10),
            addressLine2TextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLine2TextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addressLine2TextField.heightAnchor.constraint(equalToConstant: 44),
            
            cityTextField.topAnchor.constraint(equalTo: addressLine2TextField.bottomAnchor, constant: 10),
            cityTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cityTextField.heightAnchor.constraint(equalToConstant: 44),
            
            stateTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 10),
            stateTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stateTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4, constant: -25),
            stateTextField.heightAnchor.constraint(equalToConstant: 44),
            
            zipCodeTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 10),
            zipCodeTextField.leadingAnchor.constraint(equalTo: stateTextField.trailingAnchor, constant: 10),
            zipCodeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            zipCodeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: serviceTypeStackView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Add text field delegates for address validation
        addressLine1TextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipCodeTextField.delegate = self
        
        // Add editing changed actions for address fields
        addressLine1TextField.addTarget(self, action: #selector(addressFieldChanged), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(addressFieldChanged), for: .editingChanged)
        stateTextField.addTarget(self, action: #selector(addressFieldChanged), for: .editingChanged)
        zipCodeTextField.addTarget(self, action: #selector(addressFieldChanged), for: .editingChanged)
        
        // Setup address auto-completion
        setupAddressAutoCompletion()
    }
    
    private func setupAddressAutoCompletion() {
        // Configure search completer
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        
        // Create a simple table view directly
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 200))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AddressCell")
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = .white
        tableView.isHidden = true
        
        // Add table view directly to view
        view.addSubview(tableView)
        
        // Position below address field
        let addressFieldFrame = view.convert(addressLine1TextField.frame, from: addressLine1TextField.superview)
        tableView.frame.origin = CGPoint(x: addressFieldFrame.minX, y: addressFieldFrame.maxY + 5)
        
        resultsTableView = tableView
    }
    
    private func populateFields() {
        guard let user = user else { return }
        
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        
        // Hide role selection for everyone
        roleSegmentedControl.isHidden = true
        
        // Only show service types for providers
        if user.role == .provider {
            serviceTypeStackView.isHidden = false
            
            // Force update service types after a short delay to ensure UI is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.updateServiceTypeCheckboxes()
            }
        } else {
            serviceTypeStackView.isHidden = true
        }
        
        if let location = user.location {
            addressLine1TextField.text = location.address
            addressLine2TextField.text = location.addressLine2
            cityTextField.text = location.city
            stateTextField.text = location.state
            zipCodeTextField.text = location.zipCode
        }
        
        // Load profile image if available
        if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                        self?.selectedImage = image
                    }
                }
            }.resume()
        }
    }

    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func changePhotoTapped() {
        let actionSheet = UIAlertController(title: "Change Profile Photo", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }
        
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Only name fields are required
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let userData = user else {
            showAlert(title: "Error", message: "Please enter your first and last name")
            return
        }
        
        // Get address fields but don't require them
        let addressLine1 = addressLine1TextField.text ?? ""
        let city = cityTextField.text ?? ""
        let state = stateTextField.text ?? ""
        let zipCode = zipCodeTextField.text ?? ""
        
        // Only validate address if all address fields are filled
        let shouldValidateAddress = !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty
        
        // Only validate address if all address fields are filled
        if shouldValidateAddress {
            validateFullAddress { [weak self] isValid in
                guard let self = self else { return }
                
                if !isValid {
                    self.showAlert(title: "Invalid Address", message: "The address you entered appears to be invalid")
                    return
                }
                
                // Continue with saving profile
                self.continueWithSave(firstName: firstName, lastName: lastName, addressLine1: addressLine1, 
                                     city: city, state: state, zipCode: zipCode, userData: userData)
            }
        } else {
            // Skip address validation and continue with saving
            self.continueWithSave(firstName: firstName, lastName: lastName, addressLine1: addressLine1, 
                                 city: city, state: state, zipCode: zipCode, userData: userData)
        }
    }
    
    private func continueWithSave(firstName: String, lastName: String, addressLine1: String, 
                                 city: String, state: String, zipCode: String, userData: User) {
        
        activityIndicator.startAnimating()
        saveButton.isEnabled = false
        
        // Create a mutable copy of the user object
        var updatedUser = userData
        
        // Update user object
        updatedUser.firstName = firstName
        updatedUser.lastName = lastName
        
        // Keep the original role (can't change roles)
        if let originalUser = user {
            updatedUser.role = originalUser.role
        }
        
        // Update services if provider
        if updatedUser.role == .provider {
            updatedUser.servicesOffered = selectedServices
        } else {
            updatedUser.servicesOffered = nil
        }
        
        // Only update location if address fields are provided
        if !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty {
            let addressLine2 = addressLine2TextField.text ?? ""
            let location = Location(
                latitude: userData.location?.latitude ?? 0,
                longitude: userData.location?.longitude ?? 0,
                address: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                zipCode: zipCode,
                country: userData.location?.country ?? "US"
            )
            updatedUser.location = location
        }
        
        // If there's a selected image, upload it first
        if let selectedImage = selectedImage {
            uploadProfileImage(selectedImage) { [weak self] imageUrl in
                guard let self = self else { return }
                
                if let imageUrl = imageUrl {
                    updatedUser.profileImageUrl = imageUrl
                    self.saveUserData(updatedUser)
                } else {
                    self.activityIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    self.showAlert(title: "Error", message: "Failed to upload profile image. Please try again.")
                }
            }
        } else {
            saveUserData(updatedUser)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Store the image in UserDefaults for immediate access
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
        
        // Use a data URL scheme to embed the image directly
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            let base64String = imageData.base64EncodedString()
            let dataURL = "data:image/jpeg;base64," + base64String
            completion(dataURL)
        } else {
            completion(nil)
        }
    }

    
    private func saveUserData(_ user: User) {
        let db = Firestore.firestore()
        let userData = user.toDictionary()
        
        print("Saving user data to Firestore...")
        
        // First check if document exists
        db.collection("users").document(user.id).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                self.activityIndicator.stopAnimating()
                self.saveButton.isEnabled = true
                self.showAlert(title: "Error", message: "Failed to access user profile: \(error.localizedDescription)")
                return
            }
            
            if document?.exists == true {
                // Document exists, use updateData
                db.collection("users").document(user.id).updateData(userData) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.activityIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to save profile: \(error.localizedDescription)")
                        return
                    }
                    
                    print("User data updated successfully")
                    
                    // Update the user in the parent view controller
                    if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
                        profileVC.userUpdated(user)
                    }
                    
                    // Update profile images in navigation bars
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.updateProfileImagesInNavBars()
                    }
                    
                    self.showAlert(title: "Success", message: "Profile updated successfully") { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // Document doesn't exist, use setData
                db.collection("users").document(user.id).setData(userData) { [weak self] error in
                    guard let self = self else { return }
                    
                    self.activityIndicator.stopAnimating()
                    self.saveButton.isEnabled = true
                    
                    if let error = error {
                        print("Error creating document: \(error.localizedDescription)")
                        self.showAlert(title: "Error", message: "Failed to create profile: \(error.localizedDescription)")
                        return
                    }
                    
                    print("User data created successfully")
                    
                    // Update the user in the parent view controller
                    if let profileVC = self.navigationController?.viewControllers.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
                        profileVC.userUpdated(user)
                    }
                    
                    // Update profile images in navigation bars
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.updateProfileImagesInNavBars()
                    }
                    
                    self.showAlert(title: "Success", message: "Profile created successfully") { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }
    
    // MARK: - Address Validation
    
    @objc private func addressFieldChanged(_ sender: UITextField) {
        // Cancel any existing timer
        validationTimer?.invalidate()
        
        // Start a new timer to validate after user stops typing
        validationTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.validateAddressField(sender)
        }
        
        // Handle address auto-completion
        if sender == addressLine1TextField {
            if let query = sender.text, query.count >= 3 {
                print("Searching for address: \(query)")
                searchCompleter.queryFragment = query
                
                // Show results table and bring to front
                resultsTableView?.isHidden = false
                if let tableView = resultsTableView {
                    view.bringSubviewToFront(tableView)
                    
                    // Update position
                    let addressFieldFrame = view.convert(addressLine1TextField.frame, from: addressLine1TextField.superview)
                    tableView.frame = CGRect(
                        x: addressFieldFrame.minX,
                        y: addressFieldFrame.maxY + 5,
                        width: addressFieldFrame.width,
                        height: 200
                    )
                }
            } else {
                resultsTableView?.isHidden = true
            }
        }
    }
    
    private func validateAddressField(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            textField.backgroundColor = .systemBackground
            return
        }
        
        switch textField {
        case zipCodeTextField:
            if addressValidator.isValidZipCode(text) {
                textField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            } else {
                textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
            
        case stateTextField:
            // Check if it's a valid state code or convert from name
            var stateCode = text.uppercased()
            if stateCode.count != 2 {
                if let code = addressValidator.getStateCode(from: text) {
                    stateCode = code
                    textField.text = code
                    textField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                } else {
                    textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                }
            } else if addressValidator.isValidState(stateCode) {
                textField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            } else {
                textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
            
        default:
            // For address and city, just check if they're not empty
            if text.count > 2 {
                textField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            } else {
                textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            }
        }
        
        // If all required fields are filled, validate the complete address
        if let address = addressLine1TextField.text, !address.isEmpty,
           let city = cityTextField.text, !city.isEmpty,
           let state = stateTextField.text, !state.isEmpty,
           let zip = zipCodeTextField.text, !zip.isEmpty {
            validateFullAddress()
        }
    }
    
    private func validateFullAddress(completion: ((Bool) -> Void)? = nil) {
        guard let address = addressLine1TextField.text, !address.isEmpty,
              let city = cityTextField.text, !city.isEmpty,
              let state = stateTextField.text, !state.isEmpty,
              let zip = zipCodeTextField.text, !zip.isEmpty else {
            completion?(false)
            return
        }
        
        addressValidator.validateAddress(street: address, city: city, state: state, zipCode: zip) { [weak self] isValid, location, errorMessage in
            DispatchQueue.main.async {
                self?.isAddressValid = isValid
                
                if isValid, let location = location {
                    // Update latitude and longitude if address is valid
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude
                    
                    // Store these values to use when saving
                    self?.addressLine1TextField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                    self?.cityTextField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                    self?.stateTextField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                    self?.zipCodeTextField.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                } else {
                    // Address is invalid
                    self?.addressLine1TextField.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
                    self?.cityTextField.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
                    self?.stateTextField.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
                    self?.zipCodeTextField.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
                }
                
                completion?(isValid)
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateAddressField(textField)
        
        // Hide results table when done editing address field
        if textField == addressLine1TextField {
            // Delay hiding to allow selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.resultsTableView?.isHidden = true
            }
        }
    }
    
    // Add this method to ensure touch events work properly
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // When address field is tapped, make sure any previous results are hidden
        if textField != addressLine1TextField {
            resultsTableView?.isHidden = true
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Move to next field or dismiss keyboard
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            addressLine1TextField.becomeFirstResponder()
        case addressLine1TextField:
            addressLine2TextField.becomeFirstResponder()
        case addressLine2TextField:
            cityTextField.becomeFirstResponder()
        case cityTextField:
            stateTextField.becomeFirstResponder()
        case stateTextField:
            zipCodeTextField.becomeFirstResponder()
        case zipCodeTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension EditProfileViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        resultsTableView?.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Address search failed with error: \(error.localizedDescription)")
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension EditProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath)
        cell.selectionStyle = .default
        
        // Use subtitle style
        cell.textLabel?.text = searchResults[indexPath.row].title
        cell.detailTextLabel?.text = searchResults[indexPath.row].subtitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected at index: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the selected result
        let selectedResult = searchResults[indexPath.row]
        
        // Update the address field immediately
        addressLine1TextField.text = selectedResult.title
        
        // Get full address details
        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Address search error: \(error.localizedDescription)")
                return
            }
            
            guard let item = response?.mapItems.first else {
                print("No map items found")
                return
            }
            
            // Extract address components from placemark
            let placemark = item.placemark
            
            DispatchQueue.main.async {
                // Set city
                if let city = placemark.locality {
                    self.cityTextField.text = city
                }
                
                // Set state
                if let state = placemark.administrativeArea {
                    self.stateTextField.text = state
                }
                
                // Set zip code
                if let zip = placemark.postalCode {
                    self.zipCodeTextField.text = zip
                }
                
                // Hide results table
                self.resultsTableView?.isHidden = true
                
                // Validate fields
                self.validateAddressField(self.addressLine1TextField)
                self.validateAddressField(self.cityTextField)
                self.validateAddressField(self.stateTextField)
                self.validateAddressField(self.zipCodeTextField)
                
                // Force the keyboard to dismiss
                self.view.endEditing(true)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
            selectedImage = originalImage
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
import UIKit
import FirebaseAuth

protocol UsersListViewControllerDelegate: AnyObject {
    func didSelectUser(_ user: User)
}

class ChatViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.register(QuoteResponseCell.self, forCellReuseIdentifier: "QuoteResponseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let messageInputView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type a message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let quoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "dollarsign.circle"), for: .normal)
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
    var otherUserId: String!
    var otherUser: User?
    private var messages: [ChatMessage] = []
    private var messageInputBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = otherUser?.fullName ?? "Chat"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupKeyboardObservers()
        loadMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ChatService.shared.clearListeners()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(messageInputView)
        messageInputView.addSubview(messageTextField)
        messageInputView.addSubview(sendButton)
        messageInputView.addSubview(quoteButton)
        view.addSubview(activityIndicator)
        
        // Add a line at the top of the input view
        let separatorLine = UIView()
        separatorLine.backgroundColor = .systemGray4
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        messageInputView.addSubview(separatorLine)
        
        // Set up constraints
        messageInputBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 60),
            messageInputBottomConstraint,
            
            separatorLine.topAnchor.constraint(equalTo: messageInputView.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            quoteButton.leadingAnchor.constraint(equalTo: messageInputView.leadingAnchor, constant: 10),
            quoteButton.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            quoteButton.widthAnchor.constraint(equalToConstant: 30),
            quoteButton.heightAnchor.constraint(equalToConstant: 30),
            
            messageTextField.leadingAnchor.constraint(equalTo: quoteButton.trailingAnchor, constant: 10),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Set up table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        // Set up actions
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        quoteButton.addTarget(self, action: #selector(quoteButtonTapped), for: .touchUpInside)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Show/hide quote button based on user role
        if let currentUser = UserManager.shared.currentUser {
            quoteButton.isHidden = currentUser.role != .provider
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Data Loading
    private func loadMessages() {
        guard let otherUserId = otherUserId else { return }
        
        activityIndicator.startAnimating()
        
        ChatService.shared.getMessages(with: otherUserId) { [weak self] messages, error in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to load messages: \(error.localizedDescription)")
                return
            }
            
            if let messages = messages {
                self.messages = messages
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let messageText = messageTextField.text, !messageText.isEmpty else { return }
        
        sendMessage(content: messageText)
    }
    
    @objc private func quoteButtonTapped() {
        showQuoteRequestForm()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            messageInputBottomConstraint.constant = -keyboardHeight + view.safeAreaInsets.bottom
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        messageInputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func sendMessage(content: String, messageType: MessageType = .text, quoteAmount: Double? = nil, jobDescription: String? = nil, estimatedDuration: Int? = nil) {
        guard let otherUserId = otherUserId else { return }
        
        messageTextField.text = ""
        
        ChatService.shared.sendMessage(
            to: otherUserId,
            content: content,
            messageType: messageType,
            quoteAmount: quoteAmount,
            jobDescription: jobDescription,
            estimatedDuration: estimatedDuration
        ) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to send message: \(error.localizedDescription)")
            }
        }
    }
    
    private func showQuoteRequestForm() {
        let alertController = UIAlertController(title: "Send Quote", message: "Enter quote details", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Amount ($)"
            textField.keyboardType = .decimalPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Job Description"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Estimated Duration (minutes)"
            textField.keyboardType = .numberPad
        }
        
        let sendAction = UIAlertAction(title: "Send", style: .default) { [weak self, weak alertController] _ in
            guard let self = self,
                  let amountText = alertController?.textFields?[0].text,
                  let amount = Double(amountText),
                  let description = alertController?.textFields?[1].text,
                  let durationText = alertController?.textFields?[2].text,
                  let duration = Int(durationText) else {
                self?.showAlert(title: "Error", message: "Please enter valid quote details")
                return
            }
            
            let content = "Quote: $\(amount) for \(description) (Est. \(duration) min)"
            self.sendMessage(
                content: content,
                messageType: .quoteResponse,
                quoteAmount: amount,
                jobDescription: description,
                estimatedDuration: duration
            )
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(sendAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func scrollToBottom() {
        if !messages.isEmpty {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
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
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let isFromCurrentUser = message.senderId == Auth.auth().currentUser?.uid
        
        if message.messageType == .quoteRequest || message.messageType == .quoteResponse {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteResponseCell", for: indexPath) as! QuoteResponseCell
            cell.configure(with: message, isFromCurrentUser: isFromCurrentUser)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
            cell.configure(with: message, isFromCurrentUser: isFromCurrentUser)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - MessageCell
class MessageCell: UITableViewCell {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        
        // Set up constraints with leading and trailing anchors that will be activated/deactivated
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: ChatMessage, isFromCurrentUser: Bool) {
        messageLabel.text = message.content
        
        // Format time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Set bubble style based on sender
        if isFromCurrentUser {
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
            timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            
            // Round corners differently for sender
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .label
            timeLabel.textColor = .secondaryLabel
            
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            
            // Round corners differently for receiver
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
    }
}

// MARK: - QuoteResponseCell
class QuoteResponseCell: UITableViewCell {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(quoteLabel)
        bubbleView.addSubview(descriptionLabel)
        bubbleView.addSubview(durationLabel)
        bubbleView.addSubview(timeLabel)
        bubbleView.addSubview(acceptButton)
        
        // Set up constraints with leading and trailing anchors that will be activated/deactivated
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8),
            
            quoteLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            quoteLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            quoteLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            durationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            durationLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            timeLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            
            acceptButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 8),
            acceptButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            acceptButton.widthAnchor.constraint(equalToConstant: 80),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            acceptButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
        
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    func configure(with message: ChatMessage, isFromCurrentUser: Bool) {
        // Set quote details
        if let amount = message.quoteAmount {
            quoteLabel.text = "$\(amount)"
        } else {
            quoteLabel.text = "Quote"
        }
        
        descriptionLabel.text = message.jobDescription ?? message.content
        
        if let duration = message.estimatedDuration {
            durationLabel.text = "Estimated time: \(duration) minutes"
        } else {
            durationLabel.text = ""
        }
        
        // Format time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Set bubble style based on sender
        if isFromCurrentUser {
            bubbleView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            bubbleView.layer.borderColor = UIColor.systemBlue.cgColor
            quoteLabel.textColor = .systemBlue
            
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            
            // Hide accept button for sender
            acceptButton.isHidden = true
        } else {
            bubbleView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            bubbleView.layer.borderColor = UIColor.systemGreen.cgColor
            quoteLabel.textColor = .systemGreen
            
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
            
            // Show accept button for receiver if it's a quote
            acceptButton.isHidden = message.messageType != .quoteResponse
        }
        
        // Check if current user is a client or provider
        if let currentUser = UserManager.shared.currentUser {
            // Only clients can accept quotes
            acceptButton.isHidden = currentUser.role != .customer || isFromCurrentUser
        }
    }
    
    @objc private func acceptButtonTapped() {
        // In a real app, this would update the booking status
        print("Quote accepted")
    }
}
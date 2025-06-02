import UIKit
import WebKit

protocol PaymentAuthWebViewControllerDelegate: AnyObject {
    func didCompleteAuthentication(success: Bool, token: String?)
    func didCancelAuthentication()
}

class PaymentAuthWebViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: PaymentAuthWebViewControllerDelegate?
    private var paymentType: String
    private var email: String?
    
    // MARK: - UI Components
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialization
    init(paymentType: String, email: String? = nil) {
        self.paymentType = paymentType
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupWebView()
        loadAuthPage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "\(paymentType) Authentication"
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(webView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        loadingIndicator.startAnimating()
    }
    
    private func loadAuthPage() {
        var urlString: String
        
        switch paymentType {
        case "PayPal":
            urlString = "https://www.paypal.com/signin"
            if let email = email {
                urlString += "?email=\(email)"
            }
        case "Google Pay":
            urlString = "https://pay.google.com/gp/w/u/0/home/signup"
        case "Apple Pay":
            urlString = "https://secure4.store.apple.com/shop/signIn"
        default:
            urlString = "https://www.example.com"
        }
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        delegate?.didCancelAuthentication()
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension PaymentAuthWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        
        // Inject JavaScript to detect successful login
        // This is a simplified example - in a real app, you would need more sophisticated detection
        let script = """
        if (document.querySelector('.welcome-user') || 
            document.querySelector('.logged-in') || 
            document.querySelector('.account-info')) {
            'success';
        } else {
            'waiting';
        }
        """
        
        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let resultString = result as? String, resultString == "success" {
                // Generate a mock token
                let token = "AUTH-\(UUID().uuidString.prefix(8))"
                self?.delegate?.didCompleteAuthentication(success: true, token: token)
                self?.dismiss(animated: true)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        
        let alert = UIAlertController(
            title: "Connection Error",
            message: "Failed to connect to \(paymentType). Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.delegate?.didCompleteAuthentication(success: false, token: nil)
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
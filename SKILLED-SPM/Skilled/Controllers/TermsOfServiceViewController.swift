import UIKit

class TermsOfServiceViewController: UIViewController {
    
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
    
    private let termsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Terms of Service"
        view.backgroundColor = .systemBackground
        
        // Create a scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create a label for the content
        let termsLabel = UILabel()
        termsLabel.text = "TERMS OF SERVICE\n\nLast Updated: June 1, 2023\n\n1. ACCEPTANCE OF TERMS\n\nBy accessing or using the SKILLED application (\"App\"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.\n\n2. DESCRIPTION OF SERVICE\n\nSKILLED is a platform that connects homeowners with service providers for home maintenance and improvement services.\n\n3. USER ACCOUNTS\n\nYou must create an account to use certain features of the App. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.\n\n4. USER CONDUCT\n\nYou agree not to:\n- Use the App for any illegal purpose\n- Post false or misleading information\n- Impersonate any person or entity\n- Harass, abuse, or harm another person\n- Interfere with the proper working of the App\n\n5. SERVICE PROVIDERS\n\nService providers on SKILLED are independent contractors, not employees of SKILLED. SKILLED does not guarantee the quality of their work.\n\n6. PAYMENTS AND FEES\n\nSKILLED may charge fees for certain services. All fees are non-refundable unless otherwise stated.\n\n7. TERMINATION\n\nSKILLED reserves the right to terminate your access to the App for violation of these Terms.\n\n8. DISCLAIMER OF WARRANTIES\n\nThe App is provided \"as is\" without warranties of any kind.\n\n9. LIMITATION OF LIABILITY\n\nSKILLED shall not be liable for any indirect, incidental, special, consequential, or punitive damages.\n\n10. CHANGES TO TERMS\n\nSKILLED may modify these Terms at any time. Your continued use of the App constitutes acceptance of the modified Terms.\n\n11. GOVERNING LAW\n\nThese Terms shall be governed by the laws of the United States.\n\n12. CONTACT INFORMATION\n\nFor questions about these Terms, please contact support@skilled.com."
        termsLabel.numberOfLines = 0
        termsLabel.font = UIFont.systemFont(ofSize: 16)
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(termsLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            termsLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            termsLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            termsLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            termsLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
}
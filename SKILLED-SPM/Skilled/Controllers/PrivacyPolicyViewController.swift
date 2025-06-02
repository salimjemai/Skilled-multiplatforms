import UIKit

class PrivacyPolicyViewController: UIViewController {
    
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
    
    private let privacyTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Privacy Policy"
        view.backgroundColor = .systemBackground
        
        // Create a scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create a label for the content
        let privacyLabel = UILabel()
        privacyLabel.text = "PRIVACY POLICY\n\nLast Updated: June 1, 2023\n\n1. INTRODUCTION\n\nSKILLED (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and share your information.\n\n2. INFORMATION WE COLLECT\n\nWe collect the following types of information:\n\n- Personal Information: Name, email address, phone number, and address\n- Profile Information: Photos and service preferences\n- Location Information: GPS data when you use our App\n- Usage Information: How you interact with our App\n- Device Information: Device type, operating system, and browser type\n\n3. HOW WE USE YOUR INFORMATION\n\nWe use your information to:\n\n- Provide and improve our services\n- Process payments\n- Communicate with you\n- Match you with service providers\n- Ensure safety and security\n- Comply with legal obligations\n\n4. SHARING YOUR INFORMATION\n\nWe may share your information with:\n\n- Service providers on our platform\n- Third-party service providers who help us operate our business\n- Legal authorities when required by law\n\n5. YOUR CHOICES\n\nYou can:\n\n- Access and update your personal information\n- Opt out of marketing communications\n- Delete your account\n\n6. DATA SECURITY\n\nWe implement reasonable security measures to protect your information.\n\n7. CHILDREN'S PRIVACY\n\nOur App is not intended for children under 13.\n\n8. CHANGES TO THIS POLICY\n\nWe may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.\n\n9. CONTACT US\n\nIf you have questions about this Privacy Policy, please contact us at privacy@skilled.com."
        privacyLabel.numberOfLines = 0
        privacyLabel.font = UIFont.systemFont(ofSize: 16)
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(privacyLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            privacyLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            privacyLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            privacyLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            privacyLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            privacyLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
}
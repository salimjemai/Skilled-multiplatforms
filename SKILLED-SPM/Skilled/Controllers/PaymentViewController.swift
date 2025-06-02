import UIKit
import PassKit

class PaymentViewController: UIViewController {
    
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
    
    private let bookingDetailsView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let serviceNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let providerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let paymentMethodsLabel: UILabel = {
        let label = UILabel()
        label.text = "Payment Methods"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let paymentMethodsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let creditCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Credit/Debit Card", for: .normal)
        button.setImage(UIImage(systemName: "creditcard"), for: .normal)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let applePayButton: PKPaymentButton = {
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    private var booking: Booking
    private let paymentService = PaymentService()
    
    // MARK: - Initialization
    init(booking: Booking) {
        self.booking = booking
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payment"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        configureBookingDetails()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(bookingDetailsView)
        bookingDetailsView.addSubview(serviceNameLabel)
        bookingDetailsView.addSubview(providerNameLabel)
        bookingDetailsView.addSubview(dateLabel)
        bookingDetailsView.addSubview(priceLabel)
        
        contentView.addSubview(paymentMethodsLabel)
        contentView.addSubview(paymentMethodsStackView)
        
        paymentMethodsStackView.addArrangedSubview(creditCardButton)
        paymentMethodsStackView.addArrangedSubview(applePayButton)
        
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
            
            bookingDetailsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            bookingDetailsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bookingDetailsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            serviceNameLabel.topAnchor.constraint(equalTo: bookingDetailsView.topAnchor, constant: 15),
            serviceNameLabel.leadingAnchor.constraint(equalTo: bookingDetailsView.leadingAnchor, constant: 15),
            serviceNameLabel.trailingAnchor.constraint(equalTo: bookingDetailsView.trailingAnchor, constant: -15),
            
            providerNameLabel.topAnchor.constraint(equalTo: serviceNameLabel.bottomAnchor, constant: 5),
            providerNameLabel.leadingAnchor.constraint(equalTo: bookingDetailsView.leadingAnchor, constant: 15),
            providerNameLabel.trailingAnchor.constraint(equalTo: bookingDetailsView.trailingAnchor, constant: -15),
            
            dateLabel.topAnchor.constraint(equalTo: providerNameLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: bookingDetailsView.leadingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: bookingDetailsView.trailingAnchor, constant: -15),
            
            priceLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: bookingDetailsView.leadingAnchor, constant: 15),
            priceLabel.trailingAnchor.constraint(equalTo: bookingDetailsView.trailingAnchor, constant: -15),
            priceLabel.bottomAnchor.constraint(equalTo: bookingDetailsView.bottomAnchor, constant: -15),
            
            paymentMethodsLabel.topAnchor.constraint(equalTo: bookingDetailsView.bottomAnchor, constant: 30),
            paymentMethodsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentMethodsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            paymentMethodsStackView.topAnchor.constraint(equalTo: paymentMethodsLabel.bottomAnchor, constant: 15),
            paymentMethodsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentMethodsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            paymentMethodsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureBookingDetails() {
        serviceNameLabel.text = booking.serviceName
        providerNameLabel.text = "Provider: \(booking.providerName)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "Date: \(dateFormatter.string(from: booking.date))"
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        if let formattedPrice = numberFormatter.string(from: NSNumber(value: booking.price)) {
            priceLabel.text = "Total: \(formattedPrice)"
        } else {
            priceLabel.text = "Total: $\(booking.price)"
        }
    }
    
    private func setupActions() {
        creditCardButton.addTarget(self, action: #selector(creditCardPaymentTapped), for: .touchUpInside)
        applePayButton.addTarget(self, action: #selector(applePayTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func creditCardPaymentTapped() {
        // In a real app, this would show a credit card form
        // For this example, we'll just simulate a credit card payment
        processPayment(with: .creditCard)
    }
    
    @objc private func applePayTapped() {
        // In a real app, this would integrate with Apple Pay
        // For this example, we'll just simulate an Apple Pay payment
        processPayment(with: .applePay)
    }
    
    private func processPayment(with method: PaymentMethod) {
        activityIndicator.startAnimating()
        
        paymentService.createPayment(for: booking, method: method) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let payment):
                self.paymentService.processPayment(payment: payment) { processResult in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        switch processResult {
                        case .success:
                            self.showPaymentSuccess()
                        case .failure(let error):
                            self.showAlert(title: "Payment Failed", message: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "Payment Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showPaymentSuccess() {
        let alert = UIAlertController(
            title: "Payment Successful",
            message: "Your payment has been processed successfully.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
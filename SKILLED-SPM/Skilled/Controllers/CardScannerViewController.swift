import UIKit
import AVFoundation
import Vision

protocol CardScannerViewControllerDelegate: AnyObject {
    func cardScannerDidScan(cardNumber: String, expiryDate: String, cardholderName: String, cvv: String)
    func cardScannerDidCancel()
}

class CardScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Properties
    weak var delegate: CardScannerViewControllerDelegate?
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private let overlayView = UIView()
    private var lastScanTime = Date()
    private let scanCooldown: TimeInterval = 1.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scan Card"
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCapture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCapture()
    }
    
    // MARK: - Setup
    private func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            showAlert(message: "Camera not available")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        previewLayer.session = captureSession
        previewLayer.videoGravity = .resizeAspectFill
        
        self.captureSession = captureSession
    }
    
    private func setupUI() {
        // Setup preview layer
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        // Setup overlay
        overlayView.layer.borderColor = UIColor.white.cgColor
        overlayView.layer.borderWidth = 2
        overlayView.layer.cornerRadius = 10
        overlayView.backgroundColor = UIColor.clear
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Add instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Position your card in the frame"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            overlayView.heightAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.63),
            
            instructionLabel.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: -20),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Add cancel button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        delegate?.cardScannerDidCancel()
        dismiss(animated: true)
    }
    
    private func startCapture() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCapture() {
        captureSession?.stopRunning()
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Throttle processing to avoid excessive CPU usage
        let now = Date()
        guard now.timeIntervalSince(lastScanTime) > scanCooldown else { return }
        lastScanTime = now
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else { return }
            
            // Process text observations
            self?.processTextObservations(observations)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    private func processTextObservations(_ observations: [VNRecognizedTextObservation]) {
        var cardNumber: String?
        var expiryDate: String?
        var cardholderName: String?
        var cvv: String?
        
        // First pass - find card number and expiry
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string
            
            // Check for credit card number pattern
            if cardNumber == nil, let detectedCardNumber = extractCardNumber(from: text) {
                cardNumber = detectedCardNumber
                continue
            }
            
            // Check for expiry date pattern
            if expiryDate == nil, let detectedExpiryDate = extractExpiryDate(from: text) {
                expiryDate = detectedExpiryDate
                continue
            }
            
            // Check for CVV (3-4 digits)
            if cvv == nil {
                let digitsOnly = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if digitsOnly.count >= 3 && digitsOnly.count <= 4 {
                    cvv = digitsOnly
                    continue
                }
            }
        }
        
        // Second pass - look for name (typically below card number)
        if let cardNumber = cardNumber {
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                let text = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Skip if this is the card number or expiry
                if text.contains(cardNumber) || (expiryDate != nil && text.contains(expiryDate!)) {
                    continue
                }
                
                // Look for text that could be a name (2+ words, all caps)
                if text.contains(" ") && text.uppercased() == text && text.count > 5 {
                    // Make sure it's not the card number
                    if !text.contains(cardNumber) {
                        cardholderName = text
                        break
                    }
                }
            }
        }
        
        // If we found a card number, report the scan
        if let cardNumber = cardNumber {
            DispatchQueue.main.async { [weak self] in
                self?.handleSuccessfulScan(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate ?? "12/25",
                    cardholderName: cardholderName ?? "Card Holder",
                    cvv: cvv ?? ""
                )
            }
        }
    }
    
    private func extractCardNumber(from text: String) -> String? {
        // Remove all non-digits
        let digitsOnly = text.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Check if we have 16 digits (most common) or 15 (AMEX)
        if digitsOnly.count == 16 || digitsOnly.count == 15 {
            // Validate with Luhn algorithm
            if isValidCreditCard(number: digitsOnly) {
                return digitsOnly
            }
        }
        return nil
    }
    
    private func extractExpiryDate(from text: String) -> String? {
        // Look for MM/YY pattern
        let pattern = "(0[1-9]|1[0-2])[/](2[0-9])"
        if let range = text.range(of: pattern, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func isValidCreditCard(number: String) -> Bool {
        // Simple Luhn algorithm check
        var sum = 0
        let digits = number.reversed().map { Int(String($0)) ?? 0 }
        
        for (index, digit) in digits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }
    
    private func handleSuccessfulScan(cardNumber: String, expiryDate: String, cardholderName: String, cvv: String) {
        // Stop capturing
        stopCapture()
        
        // Show success feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        
        // Show success animation
        let successView = UIView(frame: view.bounds)
        successView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        successView.alpha = 0
        
        let checkmarkImage = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmarkImage.tintColor = .green
        checkmarkImage.contentMode = .scaleAspectFit
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        
        let successLabel = UILabel()
        successLabel.text = "Card Scanned Successfully"
        successLabel.textColor = .white
        successLabel.textAlignment = .center
        successLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        
        successView.addSubview(checkmarkImage)
        successView.addSubview(successLabel)
        view.addSubview(successView)
        
        NSLayoutConstraint.activate([
            checkmarkImage.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            checkmarkImage.centerYAnchor.constraint(equalTo: successView.centerYAnchor, constant: -20),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 80),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 80),
            
            successLabel.topAnchor.constraint(equalTo: checkmarkImage.bottomAnchor, constant: 20),
            successLabel.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            successLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 20),
            successLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -20)
        ])
        
        // Animate success view
        UIView.animate(withDuration: 0.3, animations: {
            successView.alpha = 1
        }, completion: { _ in
            // Dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.delegate?.cardScannerDidScan(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardholderName: cardholderName,
                    cvv: cvv
                )
                self?.dismiss(animated: true)
            }
        })
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self?.dismiss(animated: true)
            })
            self?.present(alert, animated: true)
        }
    }
}
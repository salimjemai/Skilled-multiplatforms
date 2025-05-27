import UIKit

class ServiceListViewController: UIViewController {
    
    // MARK: - UI Components
    
    // MARK: - Properties
    var selectedCategory: TradeCategory?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedCategory?.displayName ?? "Services"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add UI elements and constraints
    }
    
    // MARK: - Actions
    
}
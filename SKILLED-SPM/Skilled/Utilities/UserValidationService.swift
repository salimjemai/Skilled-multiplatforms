import Foundation
import UIKit

class UserValidationService {
    
    static let shared = UserValidationService()
    
    private init() {}
    
    /// Checks if a user has a complete address
    /// - Parameter user: The user to check
    /// - Returns: True if the user has a complete address
    func hasCompleteAddress(_ user: User?) -> Bool {
        guard let user = user,
              let location = user.location,
              !location.address.isEmpty,
              !location.city.isEmpty,
              !location.state.isEmpty,
              !location.zipCode.isEmpty else {
            return false
        }
        return true
    }
    
    /// Shows an alert prompting the user to complete their profile with address information
    /// - Parameters:
    ///   - viewController: The view controller to present the alert from
    ///   - completion: Optional completion handler
    func promptForAddressCompletion(from viewController: UIViewController, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: "Address Required",
            message: "You need to add your address information before continuing. Would you like to update your profile now?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Update Profile", style: .default) { _ in
            // Navigate to edit profile screen
            let editProfileVC = EditProfileViewController()
            if let user = UserManager.shared.currentUser {
                editProfileVC.user = user
                
                // Add a right bar button to indicate address is required
                let addressRequiredButton = UIBarButtonItem(title: "Address Required", style: .plain, target: nil, action: nil)
                addressRequiredButton.tintColor = .systemRed
                editProfileVC.navigationItem.rightBarButtonItem = addressRequiredButton
            }
            viewController.navigationController?.pushViewController(editProfileVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion?()
        })
        
        viewController.present(alert, animated: true)
    }
}

// Example extension to make it easy to check from any view controller
extension UIViewController {
    func requireCompleteAddress(for user: User?, beforeAction action: @escaping () -> Void) {
        if UserValidationService.shared.hasCompleteAddress(user) {
            action()
        } else {
            UserValidationService.shared.promptForAddressCompletion(from: self)
        }
    }
}
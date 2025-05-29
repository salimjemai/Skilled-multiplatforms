import UIKit
import FirebaseAuth

class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private init() {}
    
    func updateProfileImageInNavBar(for viewController: UIViewController) {
        guard let currentUser = UserManager.shared.currentUser,
              let imageUrl = currentUser.profileImageUrl,
              let url = URL(string: imageUrl) else {
            // Use default profile image if no custom image is available
            setupDefaultProfileImage(for: viewController)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.setupProfileButton(with: image, for: viewController)
                }
            } else {
                DispatchQueue.main.async {
                    self?.setupDefaultProfileImage(for: viewController)
                }
            }
        }.resume()
    }
    
    private func setupProfileButton(with image: UIImage, for viewController: UIViewController) {
        // Create a circular profile button
        let profileButton = UIButton(type: .custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        profileButton.layer.cornerRadius = 16
        profileButton.clipsToBounds = true
        
        // Set the image and scale it to fit
        profileButton.setImage(image, for: .normal)
        profileButton.imageView?.contentMode = .scaleAspectFill
        
        // Add border
        profileButton.layer.borderWidth = 1
        profileButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Add tap action
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        // Create bar button item with the custom button
        let barButtonItem = UIBarButtonItem(customView: profileButton)
        
        // Set as right bar button item
        viewController.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupDefaultProfileImage(for viewController: UIViewController) {
        let profileButton = UIButton(type: .custom)
        profileButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        profileButton.layer.cornerRadius = 16
        profileButton.clipsToBounds = true
        profileButton.backgroundColor = .systemGray5
        
        // Use system person icon
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        profileButton.setImage(UIImage(systemName: "person.fill", withConfiguration: config), for: .normal)
        profileButton.tintColor = .systemBlue
        
        // Add tap action
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        // Create bar button item with the custom button
        let barButtonItem = UIBarButtonItem(customView: profileButton)
        
        // Set as right bar button item
        viewController.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc private func profileButtonTapped(_ sender: UIButton) {
        // Find the tab bar controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let tabBarController = window.rootViewController as? UITabBarController {
            // Switch to settings tab (assuming it's the last tab)
            tabBarController.selectedIndex = tabBarController.viewControllers!.count - 1
        }
    }
    
    func updateProfileImageForAllTabs() {
        // Find the tab bar controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let tabBarController = window.rootViewController as? UITabBarController {
            
            // Update profile image for all navigation controllers in the tab bar
            for case let navController as UINavigationController in tabBarController.viewControllers ?? [] {
                if let topViewController = navController.topViewController {
                    updateProfileImageInNavBar(for: topViewController)
                }
            }
        }
    }
}
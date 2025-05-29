import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Firestore
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = true
        db.settings = settings
        
        return true
    }
    
    // MARK: - Profile Image Management
    func updateProfileImagesInNavBars() {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        
        // Get current user's profile image
        if let currentUser = UserManager.shared.currentUser,
           let imageUrl = currentUser.profileImageUrl,
           let url = URL(string: imageUrl) {
            
            let appDelegate = self
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    // Create circular profile button
                    let profileButton = UIButton(type: .custom)
                    profileButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                    profileButton.layer.cornerRadius = 16
                    profileButton.clipsToBounds = true
                    profileButton.setImage(image, for: .normal)
                    profileButton.imageView?.contentMode = .scaleAspectFill
                    profileButton.layer.borderWidth = 1
                    profileButton.layer.borderColor = UIColor.systemBlue.cgColor
                    
                    // Add tap action to go to settings
                    profileButton.addTarget(appDelegate, action: #selector(AppDelegate.profileButtonTapped), for: .touchUpInside)
                    
                    // Add to all navigation controllers
                    for navController in tabBarController.viewControllers?.compactMap({ $0 as? UINavigationController }) ?? [] {
                        let barButtonItem = UIBarButtonItem(customView: profileButton)
                        navController.topViewController?.navigationItem.rightBarButtonItem = barButtonItem
                    }
                }
            }.resume()
        } else {
            // Use default profile icon if no image is available
            let appDelegate = self
            DispatchQueue.main.async {
                let profileButton = UIButton(type: .custom)
                profileButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                profileButton.layer.cornerRadius = 16
                profileButton.clipsToBounds = true
                profileButton.backgroundColor = .systemGray5
                
                // Use system person icon
                let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
                profileButton.setImage(UIImage(systemName: "person.fill", withConfiguration: config), for: .normal)
                profileButton.tintColor = .systemBlue
                
                // Add tap action to go to settings
                profileButton.addTarget(appDelegate, action: #selector(AppDelegate.profileButtonTapped), for: .touchUpInside)
                
                // Add to all navigation controllers
                for navController in tabBarController.viewControllers?.compactMap({ $0 as? UINavigationController }) ?? [] {
                    let barButtonItem = UIBarButtonItem(customView: profileButton)
                    navController.topViewController?.navigationItem.rightBarButtonItem = barButtonItem
                }
            }
        }
    }
    
    @objc func profileButtonTapped() {
        if let tabBarController = window?.rootViewController as? UITabBarController {
            // Switch to settings tab (assuming it's the last tab)
            tabBarController.selectedIndex = tabBarController.viewControllers!.count - 1
        }
    }
}

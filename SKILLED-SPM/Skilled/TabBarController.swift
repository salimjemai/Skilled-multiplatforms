import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupViewControllers() {
        // Home Tab
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Messages Tab (with service providers)
        let messagesVC = MessagesTabViewController()
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        messagesNav.tabBarItem = UITabBarItem(title: "Messages", image: UIImage(systemName: "message"), tag: 1)
        
        // Bookings Tab
        let bookingsVC = BookingsViewController()
        let bookingsNav = UINavigationController(rootViewController: bookingsVC)
        bookingsNav.tabBarItem = UITabBarItem(title: "Bookings", image: UIImage(systemName: "calendar"), tag: 2)
        
        // Settings Tab
        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 3)
        
        // Set view controllers
        viewControllers = [homeNav, messagesNav, bookingsNav, settingsNav]
    }
    
    private func setupAppearance() {
        // Set tab bar appearance
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
        
        // Add a top border to the tab bar
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        topBorder.backgroundColor = UIColor.systemGray5.cgColor
        tabBar.layer.addSublayer(topBorder)
    }
}
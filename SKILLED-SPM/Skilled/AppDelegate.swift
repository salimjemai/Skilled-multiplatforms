import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import FirebaseCore
import SystemConfiguration
import IQKeyboardManagerSwift
// For Analytics
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var reachability: SCNetworkReachability?
    
    // Check if network is reachable
    func isNetworkReachable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Firebase properly
        let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        if let filePath = filePath {
            print("Firebase: Found GoogleService-Info.plist at \(filePath)")
        } else {
            print("Firebase: ERROR - GoogleService-Info.plist not found!")
        }
        
        // Disable Firebase diagnostics collection
        Analytics.setAnalyticsCollectionEnabled(false)
        
        do {
            // Ensure Firebase app is not already configured
            if FirebaseApp.app() == nil {
                // Add a small delay to ensure initialization completes properly
                Thread.sleep(forTimeInterval: 0.3)
                FirebaseApp.configure()
                print("Firebase: Successfully configured")
            } else {
                print("Firebase: Already configured")
            }
        } catch let error {
            print("Firebase: Error configuring Firebase - \(error.localizedDescription)")
        }
        
        // Then configure Firestore with proper settings
        let db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        // Set cache size based on network availability
        if isNetworkReachable() {
            print("Network is reachable, configuring Firebase...")
            // Standard cache size for online mode
            settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        } else {
            print("Network is not reachable, configuring Firebase in offline mode...")
            // Unlimited cache size for offline mode
            settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        }
        
        // Apply settings to Firestore
        db.settings = settings
        
        // Enable analytics debug mode for development
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
        #endif
        
        // Set up Firebase Messaging
        setupMessaging(application)
        
        // For iOS < 13.0 only
        if #available(iOS 13.0, *) {
            // Scene delegate will handle window setup
        } else {
            // Create the app's window for older iOS versions
            window = UIWindow(frame: UIScreen.main.bounds)
            
            // Set the initial view controller
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
        // Customize the appearance
        setupAppearance()
        
        // Set up IQKeyboardManager
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false  // Disable the toolbar
        
        return true
    }
    
    private func setupAppearance() {
        // Customize navigation bar appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        
        // Customize tab bar appearance
        UITabBar.appearance().tintColor = .systemBlue
        
        // If you're using iOS 15+, you can use the following to customize the navigation bar:
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func setupMessaging(_ application: UIApplication) {
        // Set messaging delegate
        Messaging.messaging().delegate = self
        
        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
    }

    // MARK: UISceneSession Lifecycle (iOS 13+)
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session
    }
    
    // MARK: - Push Notification Handling
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass the device token to Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        
        // Convert token to string (for logging or sending to your server)
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle the received notification
        print("Received remote notification: \(userInfo)")
        
        // If the notification contains Firebase Messaging data, pass it to Firebase
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Handle notification content
        completionHandler(.newData)
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        // Store this token to your server for sending notifications to this device
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // Save the token to UserDefaults for later use
        if let token = fcmToken {
            UserDefaults.standard.set(token, forKey: "fcmToken")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle incoming notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message for debugging
        print("Received notification while app in foreground: \(userInfo)")
        
        // Change this to your preferred presentation options
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification response when user taps on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message for debugging
        print("User tapped on notification: \(userInfo)")
        
        // Handle the notification tap - navigate to specific content
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID from tapped notification: \(messageID)")
            // TODO: Add navigation logic here based on notification content
        }
        
        completionHandler()
    }
}
# Skilled

Skilled is an iOS application that connects users with skilled trade service providers. The app allows users to browse, book, and review various trade services.

## Features

- User authentication (email, password, and Apple Sign In)
- Browse available trade services
- View detailed service provider information
- Book services
- Manage bookings
- User profiles
- Location-based service discovery
- Review system

## Project Structure

- **Controllers**: Contains all view controllers that manage the app's UI
- **Models**: Data models representing core entities like User, TradeService, and Booking
- **Services**: Business logic and API communication layers
- **Helpers**: Utility classes and shared types
- **Views**: Custom UI components

## Technologies

- Swift
- UIKit
- Core Data
- Firebase (Authentication, Firestore, Storage)
- Swift Package Manager for dependency management

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/SKILLED-SPM.git
cd SKILLED-SPM
```

2. Open the Xcode project
```bash
open Skilled.xcodeproj
```

3. Build and run the application

## Configuration

Make sure to add your own `GoogleService-Info.plist` file from Firebase to the project's Resources folder.

## Testing

The project includes unit tests and UI tests that can be run from Xcode's Test Navigator.

## License

[Specify your license here]

## Contact

[Your contact information]
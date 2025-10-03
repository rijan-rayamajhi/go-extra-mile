# Go Extra Mile (GEM) - Ride & Earn App

<div align="center">
  <img src="assets/images/app_logo.PNG" alt="GEM Logo" width="200"/>
  
  [![Flutter Version](https://img.shields.io/badge/Flutter-3.8.0+-blue.svg)](https://flutter.dev/)
  [![Dart Version](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)](https://dart.dev/)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev/)
  [![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-red.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
  [![State Management](https://img.shields.io/badge/State%20Management-BLoC-orange.svg)](https://bloclibrary.dev/)
</div>

## 📱 Overview

**Go Extra Mile (GEM)** is a comprehensive Flutter application that enables users to track their rides, earn rewards, and manage their vehicles. The app follows a "Ride & Earn" model where users can accumulate GEM coins through various activities like daily rewards, ride completion, referrals, and more.

## ✨ Key Features

### 🚗 **Vehicle Management**
- Register and manage multiple vehicles (2-wheelers, 4-wheelers)
- Upload vehicle documents (RC, Insurance, Images)
- Admin verification system
- Support for electric vehicles

### 🏍️ **Ride Tracking**
- Real-time GPS tracking during rides
- Route recording and visualization
- Ride memories (photos/videos)
- Odometer reading integration
- Offline ride storage with cloud sync

### 💰 **GEM Coin System**
- Virtual currency for rewards
- Multiple earning opportunities:
  - Daily scratch & earn rewards
  - Ride completion bonuses
  - Referral program rewards
  - Product purchase rewards
  - Special event rewards
- Comprehensive transaction history

### 🏆 **Leaderboards & Social**
- Top riders rankings
- Referral leaderboards
- User statistics and achievements
- Social sharing capabilities

### 🔔 **Notifications**
- Push notifications via FCM
- Local notifications
- Real-time updates
- Notification history

### 👤 **User Management**
- Google & Apple Sign-In
- Profile management
- Username availability checking
- Account deletion/restoration

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **Domain-Driven Design (DDD)**:

```
lib/
├── core/                    # Core utilities and services
│   ├── constants/          # App constants
│   ├── di/                 # Dependency injection
│   ├── error/              # Error handling
│   ├── service/            # Core services
│   ├── theme/              # App theming
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── home/               # Dashboard
│   ├── vehicle/            # Vehicle management
│   ├── ride/               # Ride tracking
│   ├── gem_coin/           # Virtual currency
│   ├── profile/            # User profile
│   ├── notification/       # Notifications
│   ├── referral/           # Referral system
│   ├── license/            # License management
│   ├── reward/             # Daily rewards
│   ├── leaderboard/        # Rankings
│   ├── monetization/       # Earnings
│   └── redeem/             # Redemption
└── common/                 # Shared modules
```

### State Management
- **BLoC Pattern** for state management
- **Equatable** for state comparison
- **GetIt** for dependency injection

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.8.0+** - Cross-platform framework
- **Dart 3.0.0+** - Programming language
- **BLoC** - State management
- **GetIt** - Dependency injection
- **Hive** - Local database
- **Google Maps** - Maps and location

### Backend & Services
- **Firebase Auth** - Authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Firebase Messaging** - Push notifications
- **Google Sign-In** - Social authentication
- **Apple Sign-In** - Social authentication

### Additional Packages
- **Geolocator** - GPS tracking
- **Image Picker** - Photo/video capture
- **Shimmer** - Loading animations
- **Cached Network Image** - Image caching
- **WebView** - In-app browsing
- **Share Plus** - Social sharing

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project setup
- Google Services configuration

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd go_extra_mile_new
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the respective platform directories

4. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Environment Configuration

Create environment files for different build configurations:

```bash
# Copy template
cp env.dev.template env.dev

# Edit with your configuration
# Add Firebase configuration
# Add API keys
# Add other environment-specific settings
```

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Responsive Design**: Optimized for various screen sizes

## 🔧 Development

### Code Generation
The project uses code generation for:
- Hive adapters for local storage
- Freezed for immutable data classes
- Injectable for dependency injection

Run code generation:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/
```

### Building

#### Android
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

#### iOS
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

## 📊 Features Overview

### 🏠 Home Dashboard
- User profile overview
- Recent rides display
- GEM coin balance
- Quick navigation to features
- Leaderboard preview
- Statistics overview

### 🚗 Vehicle Management
- **Add Vehicle**: Select type, brand, model
- **Document Upload**: RC, Insurance, Images
- **Verification**: Admin approval process
- **Vehicle History**: Track all vehicles

### 🏍️ Ride Tracking
- **Start/Stop Rides**: GPS tracking
- **Route Recording**: Real-time path tracking
- **Memories**: Capture photos/videos
- **Odometer**: Manual readings with photos
- **Analytics**: Distance, speed, time
- **Offline Support**: Local storage with sync

### 💰 GEM Coin System
- **Earning Methods**:
  - Daily scratch & earn (up to 10 coins)
  - Ride completion rewards
  - Referral bonuses (50 coins per referral)
  - Product purchase rewards
  - Special event rewards
- **Transaction History**: Complete audit trail
- **Filtering**: By type, reward category, time range

### 🔔 Notifications
- **Push Notifications**: FCM integration
- **Local Notifications**: App-generated alerts
- **Categories**: System, promotional, ride updates
- **Read/Unread**: Status tracking

### 👥 Social Features
- **Referral System**: Invite friends, earn rewards
- **Leaderboards**: Top riders, referral rankings
- **Profile Sharing**: Social media integration
- **Achievements**: Badges and milestones

## 🗄️ Database Schema

### Firestore Collections

#### Users
```javascript
users/{uid}/
  - displayName: string
  - email: string
  - photoUrl: string
  - userName: string
  - referralCode: string
  - fcmToken: string
  - createdAt: timestamp
```

#### Vehicles
```javascript
vehicles/{vehicleId}/
  - userId: string
  - vehicleType: string
  - vehicleBrandName: string
  - vehicleModelName: string
  - vehicleRegistrationNumber: string
  - verificationStatus: string
  - vehicleImages: object
  - createdAt: timestamp
```

#### Rides
```javascript
rides/{rideId}/
  - userId: string
  - vehicleId: string
  - status: string
  - startCoordinates: geopoint
  - endCoordinates: geopoint
  - totalDistance: number
  - totalTime: number
  - totalGEMCoins: number
  - routePoints: array
  - createdAt: timestamp
```

#### Gem Coin History
```javascript
users/{uid}/gem_coin_history/{transactionId}/
  - type: string (credit/debit)
  - rewardType: string
  - amount: number
  - balanceAfter: number
  - reason: string
  - date: timestamp
```

## 🔐 Security & Privacy

- **Firebase Security Rules**: Comprehensive Firestore rules
- **Authentication**: Secure Google/Apple Sign-In
- **Data Encryption**: Local data encryption with Hive
- **Privacy**: GDPR compliant data handling
- **Permissions**: Minimal required permissions

## 📈 Performance

- **Local Storage**: Hive for offline capabilities
- **Image Caching**: Cached network images
- **Lazy Loading**: Efficient data loading
- **Memory Management**: Optimized image handling
- **Background Services**: GPS tracking optimization

## 🧪 Testing

### Test Coverage
- **Unit Tests**: Business logic and utilities
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end flows
- **BLoC Tests**: State management testing

### Test Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Deployment

### Android Play Store
1. Generate signed APK/AAB
2. Upload to Play Console
3. Configure release settings
4. Publish to production

### iOS App Store
1. Archive in Xcode
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

### Firebase Hosting (Web)
```bash
# Build for web
flutter build web

# Deploy to Firebase
firebase deploy --only hosting
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development**: Flutter Development Team
- **Design**: UI/UX Design Team
- **Backend**: Firebase & Cloud Services
- **QA**: Quality Assurance Team

## 📞 Support

- **Email**: support@goextramile.com
- **Documentation**: [Wiki](https://github.com/your-repo/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-repo/issues)

## 🔄 Version History

- **v0.0.5+4** - Current version with all core features
- **v0.0.4** - Added referral system and leaderboards
- **v0.0.3** - Implemented GEM coin system
- **v0.0.2** - Added ride tracking and vehicle management
- **v0.0.1** - Initial release with authentication

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Community contributors and testers
- Beta users for feedback and suggestions

---

<div align="center">
  <p>Made with ❤️ by the Go Extra Mile Team</p>
  <p>© 2025 Go Extra Mile. All rights reserved.</p>
</div>
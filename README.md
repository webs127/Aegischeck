# AegisCheck

A modern, secure, and offline-first attendance tracking system built with Flutter. AegisCheck replaces traditional paper-based attendance methods with QR code scanning, providing organizations, schools, events, and gyms with a fast, fraud-resistant solution for tracking attendance.

## 🚀 Features

### Core Functionality
- **QR Code Attendance**: Generate and scan QR codes for instant attendance marking
- **Real-time Tracking**: Live attendance monitoring with immediate status updates
- **Multi-tenant Architecture**: Organization-based access control and data isolation
- **Role-based Access**: Admin and employee/staff user roles with appropriate permissions
- **Offline-First Design**: Continue scanning attendance even without internet connectivity
- **Automatic Sync**: Seamless synchronization when connectivity is restored

### Security & Compliance
- **Device Binding**: One account per device to prevent unauthorized access
- **Firebase Authentication**: Secure user authentication with email/password
- **Firestore Security Rules**: Granular data access controls
- **Encrypted Data Storage**: Secure local storage for offline records

### User Experience
- **Cross-platform**: Native Android, iOS, Web, and Windows support
- **Intuitive UI**: Clean, modern interface designed for efficiency
- **Real-time Notifications**: Instant feedback on attendance actions
- **Policy Configuration**: Flexible attendance rules and time windows
- **Dashboard Analytics**: Comprehensive reporting and insights

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Auth, Firestore, Hosting)
- **State Management**: Provider (MVVM pattern)
- **Local Storage**: Hive (offline data persistence)
- **Navigation**: Go Router
- **Device Info**: Device binding with device_info_plus

### Project Structure
```
lib/
├── core/                    # Core utilities and services
│   ├── managers/           # Color, theme, and UI managers
│   ├── models/             # Data models
│   ├── service/            # Firebase and external services
│   └── widgets/            # Shared UI components
├── features/               # Feature modules
│   ├── auth/               # Authentication system
│   │   ├── models/         # Auth data models
│   │   ├── repositry/      # Auth repository layer
│   │   ├── service/        # Auth services
│   │   ├── viewmodels/     # Auth business logic
│   │   └── views/          # Auth UI screens
│   ├── employees/          # Employee management
│   ├── home/               # Main dashboard
│   ├── landing/            # Landing/onboarding
│   ├── qr/                 # QR attendance system
│   ├── settings/           # App settings
│   └── shared/             # Shared components
├── routes/                 # Navigation configuration
└── main.dart              # App entry point
```

### Key Components

#### Authentication System
- **Device Binding**: Ensures one account per physical device
- **Session Management**: Automatic logout on device mismatch
- **Profile Loading**: Loads user profile and organization context on login
- **Error Handling**: Clear error messages for authentication failures

#### QR Attendance System
- **Dynamic QR Generation**: Time-limited QR codes with expiry
- **Policy Enforcement**: Configurable check-in/check-out windows
- **Offline Support**: Local storage and background sync
- **Validation**: Prevents duplicate and fraudulent entries

#### Data Synchronization
- **Connectivity Monitoring**: Real-time network status tracking
- **Batch Sync**: Efficient upload of offline records
- **Conflict Resolution**: Handles sync conflicts gracefully
- **Progress Tracking**: Visual sync status indicators

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Firebase project with Authentication and Firestore enabled
- Android Studio / Xcode for mobile development
- Git for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/aegischeck.git
   cd aegischeck
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Email/Password) and Firestore
   - Download `google-services.json` for Android and place in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and place in `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase config

4. **Configure Firestore Security Rules**
   - Copy the rules from `firestore.rules` to your Firebase project
   - Deploy the rules: `firebase deploy --only firestore:rules`

5. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 🔐 Security Features

### Device Binding
- Each account is permanently bound to a specific device
- Prevents account sharing and unauthorized access
- Automatic logout when accessed from different devices

### Data Protection
- Firestore security rules enforce organization-level data isolation
- Encrypted local storage for offline attendance records
- Secure authentication with Firebase Auth

### Access Control
- Role-based permissions (Admin, Employee/Staff)
- Organization-scoped data access
- API-level security validations

## 📱 Usage

### For Administrators
1. **Setup Organization**: Create account and configure organization settings
2. **Configure Policies**: Set attendance rules, time windows, and requirements
3. **Manage Users**: Add employees/staff and assign roles
4. **Monitor Attendance**: View real-time attendance data and reports

### For Employees/Staff
1. **Login**: Authenticate with email/password (device-bound)
2. **Generate QR**: Create time-limited attendance QR codes
3. **Scan Attendance**: Use camera to scan QR codes for attendance marking
4. **View Status**: Check attendance history and current status

## 🔄 Offline Functionality

AegisCheck works seamlessly offline:
- **Scan QR Codes**: Continue marking attendance without internet
- **Local Storage**: Attendance records stored securely on device
- **Auto Sync**: Automatic upload when connectivity returns
- **Sync Status**: Visual indicators show sync progress and errors

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add your feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a pull request

### Code Style
- Follow Flutter's [effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check code quality
- Write tests for new features

## 📄 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Contact the development team
- Check the documentation in `OFFLINE_IMPLEMENTATION.md` for technical details

## 🗺️ Roadmap

- [ ] Mobile app store releases
- [ ] Web dashboard for administrators
- [ ] Advanced reporting and analytics
- [ ] Integration with calendar systems
- [ ] Multi-language support
- [ ] Biometric authentication options

<div align="center">

# Livora
  
*A Premium Professional Directory & Social Network*

</div>

---

## 🌟 Overview

**Livora** is a fully-featured, cross-platform social networking and directory application built with Flutter. It uniquely blends professional networking capabilities with engaging social interactions, wrapped in a stunning high-contrast "Premium Red & Black" aesthetic. 

From live streaming functionality to interactive background animations, Livora delivers a best-in-class user experience.

## ✨ Key Features

- **🔐 Robust Authentication:**
  - Secure login, registration, and password recovery via Firebase Auth.
  - Multi-step pending approval workflows for regulated access.
- **🌐 Social Hub:**
  - Interactive social feeds with post creation.
  - In-depth user profiles with connections tracking and recent activity feeds.
- **🏢 Professional Directory:**
  - Browse and connect with verified organizations.
  - Granular organization profiles and subscription management.
- **🎥 Multimedia & Live Streams:**
  - Integrated video players (`better_player`, `flutter_inappwebview`, `chewie`).
  - HLS streams and Facebook Live support with fallback UI and robust error handling.
- **🛡️ Admin Dashboard:**
  - Comprehensive tools for managing users, organizations, and approving new accounts.
- **🎨 Premium UI/UX:**
  - Distinctive monochrome Red & Black aesthetic optimized for Dark Mode.
  - Dynamic user interfaces with customized cursor effects and floating gradient paths.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.10.7)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Backend/BaaS:** Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **Navigation:** `go_router`
- **Networking:** `dio`
- **Data Persistence:** `hive`, `flutter_secure_storage`, `shared_preferences`

## 📂 Project Structure

```text
lib/
├── core/            # Design system, shared widgets, config, and core utilities.
├── features/        # Feature-first modular codebase
│   ├── admin/       # Management screens for system administrators
│   ├── auth/        # Firebase authentication workflows
│   ├── directory/   # Professional directory browsing & search
│   ├── home/        # Main dashboard and Livewall aggregator
│   ├── live/        # Live streaming and multimedia players
│   ├── organizations/ # Org profiles and management logic
│   ├── profile/     # Personal user settings and preferences
│   └── social/      # Posts, Connections, and Feed interaction
└── main.dart        # Entry point and routing configuration
```

## 🚀 Getting Started

Follow these steps to run Livora locally.

### Prerequisites

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (Ensure versions match the `sdk: ^3.10.7` constraint).
2. Configure a corresponding Firebase project and ensure valid Firebase configuration files `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are set up.

### Installation

1. Navigate to the Livora directory:
   ```bash
   cd livora
   ```
2. Install Dart/Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the Flutter code generator to fetch needed Riverpod/Hive boilerplate:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## 📜 License & Acknowledgements

- Designed and developed for the Livora Professional Network.
- Built with ❤️ using Flutter by Harshitha.

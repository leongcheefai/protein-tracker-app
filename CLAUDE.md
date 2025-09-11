# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a protein tracking mobile application with a Flutter frontend and Express.js backend. The app allows users to track protein intake through food photo capture and analysis, with features for authentication, meal logging, and nutrition analytics.

## Project Structure

```
protein-tracker/
├── backend/               # Express.js API server
│   ├── index.js          # Main server entry point
│   └── package.json      # Backend dependencies
└── frontend/             # Flutter mobile application
    ├── lib/
    │   ├── main.dart     # App entry point with routing
    │   ├── screens/      # UI screens (43 screens)
    │   ├── utils/        # Utility functions and providers
    │   └── widgets/      # Reusable UI components
    ├── pubspec.yaml      # Flutter dependencies
    └── PHASE_6_README.md # Implementation documentation
```

## Development Commands

### Backend (Node.js/Express)
```bash
cd backend
npm install           # Install dependencies
node index.js         # Run server (port 3000)
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get       # Install dependencies
flutter run           # Run on connected device/emulator
flutter run -d chrome # Run web version
flutter build ios     # Build for iOS
flutter build android # Build for Android
flutter test          # Run tests
flutter analyze       # Static analysis
```

## Architecture & Key Components

### Frontend Architecture
- **State Management**: Provider pattern (`provider: ^6.1.1`)
- **Navigation**: CupertinoPageRoute with comprehensive routing in main.dart
- **Design System**: iOS-focused with Cupertino widgets
- **Authentication**: Supabase Auth with Google Sign-In, Sign in with Apple and email
- **Camera Integration**: Custom camera functionality for food photo capture

### Core User Flows
1. **Authentication Flow**: Welcome → Email/Social Login → Verification → Profile Setup
2. **Photo Capture Flow**: Camera Launch → Photo Capture → Processing → Food Detection → Portion Selection → Meal Assignment → Confirmation
3. **Analytics Flow**: Home → History → Stats Overview → Meal Breakdown

### Key Screens Organization
- **Authentication**: `authentication_welcome_screen.dart`, `email_login_screen.dart`, `email_signup_screen.dart`
- **Camera/Food Capture**: `camera_launch_screen.dart`, `photo_capture_screen.dart`, `food_detection_results_screen.dart`
- **Data Entry**: `portion_selection_screen.dart`, `meal_assignment_screen.dart`, `confirmation_screen.dart`
- **Analytics**: `user_home_screen.dart`, `history_screen.dart`, `stats_overview.dart`
- **Settings**: `profile_settings_screen.dart`, `notification_settings_screen.dart`, `privacy_settings_screen.dart`
- **Error Handling**: `permission_denied_screen.dart`, `network_error_screen.dart`, `empty_states_screen.dart`

### Backend Architecture
- Simple Express.js server with basic "Hello World" endpoint
- Currently minimal implementation - likely placeholder for future API development

## Key Dependencies

### Frontend
- **Core**: `flutter`, `cupertino_icons`
- **State**: `provider`
- **Camera**: `camera`, `image_picker`, `permission_handler`
- **Auth**: `firebase_core`, `firebase_auth`, `google_sign_in`, `sign_in_with_apple`

### Backend
- **Framework**: `express ^5.1.0`

## Development Guidelines

### Code Style
- Follow Flutter/Dart conventions with CupertinoApp design system
- Screens use Cupertino widgets for iOS-native feel
- State management through Provider pattern
- Comprehensive error handling with dedicated error screens

### File Naming
- Screens: `*_screen.dart` (snake_case)
- Utilities: `*_utils.dart` or `*_provider.dart`
- Widgets: Component-based naming in `widgets/` directory

### Authentication Integration
- Firebase Auth is configured for production use
- Support for email/password, Google Sign-In, and Sign in with Apple
- Account linking functionality implemented

### Testing
- Use `flutter test` to run widget and unit tests
- Test files should be in `frontend/test/` directory

## Common Development Tasks

### Adding New Screens
1. Create new screen file in `frontend/lib/screens/`
2. Import and add route in `main.dart`
3. Follow existing Cupertino design patterns

### Working with Camera Features
- Camera permissions handled through `permission_handler`
- Custom camera implementation in `camera_launch_screen.dart`
- Image processing flow through multiple screens

### State Management
- Global app state managed through `UserSettingsProvider`
- Screen-specific state using StatefulWidget or Provider consumers

### Error Handling
- Use existing error screens: `PermissionDeniedScreen`, `NetworkErrorScreen`, `EmptyStatesScreen`
- Follow established error handling patterns documented in PHASE_6_README.md
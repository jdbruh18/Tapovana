# Tapovana - Trekker Micro-Stay Platform

A mobile-first platform built for backpackers, trekkers, and local homestays. It solves the gap between full-day hotel bookings and the real needs of on-the-move travelers who require short, safe, [...]

## Features

- 🔍 **Search & Discover**: Find verified micro-stays in popular trekking destinations
- ⏱️ **Flexible Durations**: Book stays from 30 minutes up to 4 hours
- 🔒 **Verified Hosts**: Only verified homestays listed for safety
- 💳 **Simple Checkout**: Quick and easy booking process
- 📱 **Cross-Platform**: Works on iOS, Android, Web, Windows, macOS, and Linux

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Dart (Native HTTP Server)
- **State Management**: In-memory (for MVP)
- **Architecture**: Single-file MVP (ready to scale)

## Recent Improvements

_Last updated: 2026-05-12_

- ✅ Improved cross-platform support by removing web-only `dart:html` dependencies (uses `http` package instead)
- ✅ Security hardening: proxy domain whitelist + strict SSL validation
- ✅ Safer JSON parsing with null checks (more robust null safety)
- ✅ Performance: in-memory caching for frequently requested server responses
- ✅ Fixed timer logic and time wrapping issues affecting short-duration booking flows
- ✅ Updated `.gitignore` to properly exclude external Flutter SDK and build artifacts

## Getting Started

### Prerequisites

- Flutter SDK (^3.9.2)
- Dart SDK (^3.9.2)

### Installation

 1. **Clone the repository**:
    ```bash
    git clone https://github.com/jdbruh18/Tapovana.git
    cd Tapovana
    ```

 2. **Install dependencies**:
    ```bash
    flutter pub get
    ```

 3. **Start the backend server**:
    ```bash
    dart run server/server.dart
    ```
    The server will run at http://localhost:8080

 4. **Run the Flutter app**:
    ```bash
    # On Chrome (web)
    flutter run -d chrome

    # On Windows
    flutter run -d windows

    # On Android/iOS (connect device first)
    flutter run
    ```

## Project Structure

```
Tapovana/
├── lib/                # Flutter app modules
│   ├── main.dart      # Entry point
│   ├── app.dart       # App bootstrap/theme
│   ├── core/          # Shared config/network/errors
│   └── features/      # Search, booking, auth, notifications
├── server/             # Backend server
│   ├── server.dart    # Server entrypoint
│   └── src/           # Router, handlers, services, repositories
├── host_portal/       # Host portal (future feature)
├── pubspec.yaml       # Flutter dependencies
└── README.md          # This file
```

## Environment Variables

You can configure the API base URL using the `API_BASE_URL` environment variable:

```bash
# For production
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com

# For development (default)
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Additional optional integration hooks:

```bash
# Flutter placeholders
flutter run --dart-define=RAZORPAY_KEY_ID=rzp_test_xxx

# Server placeholders
dart run --define=RAZORPAY_KEY_ID=rzp_test_xxx \
  --define=RAZORPAY_KEY_SECRET=secret \
  --define=OTP_PROVIDER=firebase \
  --define=SMS_PROVIDER=msg91 \
  server/server.dart
```

## Key Fixes & Improvements

 1. **Cross-platform support**: Replaced web-only `dart:html` with `http` package
 2. **Security**: Added proxy domain whitelist, enabled strict SSL validation
 3. **Null safety**: Robust JSON parsing with null checks
 4. **Performance**: Added in-memory caching for server responses
 5. **Time handling**: Fixed timer logic and time wrapping issues
 6. **Git ignore**: Properly excluded external Flutter SDK and build artifacts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with Flutter 💙
- For backpackers and trekkers everywhere 🥾

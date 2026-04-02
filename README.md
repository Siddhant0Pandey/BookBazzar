# 📦 BookBaazar — Offline Inventory & Credit Tracker

> A production-ready Flutter app for street vendors to manage inventory,
> record sales, and track customer credit — 100% offline, no internet needed.

---

## 🚀 Quick Start

```bash
# 1. Extract the ZIP and navigate into the folder
cd bookbaazar

# 2. Install dependencies
flutter pub get

# 3. Generate localisation files (REQUIRED before running)
flutter gen-l10n

# 4. Generate app icons (REQUIRED once)
dart run flutter_launcher_icons

# 5. Run the app
flutter run
```

---

## 🏗️ Build for Production

### Android APK (for direct install)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS + Xcode)
```bash
flutter build ios --release
```

---

## 🔑 Signing the APK (required for release)

### 1. Generate a keystore (one time only):
```bash
keytool -genkey -v -keystore ~/bookbaazar-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias bookbaazar
```

### 2. Create `android/key.properties`:
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=bookbaazar
storeFile=/path/to/bookbaazar-release.jks
```

### 3. Update `android/app/build.gradle` — add before `android {}`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Then add signingConfigs inside `android {}`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, routing
├── l10n/                        # Localisation (English + Nepali)
├── models/                      # Data models (Product, Sale, Customer, Credit)
├── database/                    # SQLite helper (database_helper.dart)
├── services/                    # Business logic per entity
├── providers/                   # AppProvider — global state (ChangeNotifier)
├── screens/
│   ├── splash_screen.dart       # Animated logo splash
│   ├── registration_screen.dart # First-time setup
│   ├── main_shell.dart          # Bottom nav shell
│   ├── dashboard/               # Home — today's report
│   ├── products/                # Inventory management
│   ├── sales/                   # Add sale flow
│   ├── customers/               # Customer & credit management
│   ├── summary/                 # Daily reports with date picker
│   └── settings/                # Language, logout, reset
├── widgets/                     # Reusable UI components
└── utils/                       # AppColors, AppTheme, AppFormat
assets/
└── images/
    ├── app_icon.png             # Source icon for flutter_launcher_icons
    └── logo_sm.png              # In-app logo usage
```

---

## ✨ Features

| Feature | Details |
|---|---|
| 📦 Inventory | Add/edit/delete products with emoji icons and low-stock alerts |
| 🛒 Sales | 3-step sale flow: product → quantity → cash or credit |
| 👥 Customers | Track credit per customer, collect payments, view history |
| 📊 Daily Reports | Revenue, cash, credit breakdown with date navigation |
| 🌐 Bilingual | English + Nepali (नेपाली) |
| 📵 100% Offline | SQLite — no internet, no server, no account needed |
| 🔒 Secure | All data stays on device |

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Database | SQLite via `sqflite` |
| State | `provider` (ChangeNotifier) |
| Localisation | `flutter_localizations` + ARB files |
| Persistence | `shared_preferences` for user settings |
| Icons | `flutter_launcher_icons` |

---

## 📋 Minimum Requirements

| Platform | Version |
|---|---|
| Flutter SDK | 3.0.0+ |
| Dart SDK | 3.0.0+ |
| Android | API 21 (Android 5.0+) |
| iOS | 12.0+ |

---

*BookBaazar v1.0.0 — BCA Final Project*

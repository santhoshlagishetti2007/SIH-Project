# Sanchari — Mobile App Build & Release Guide 📱

This document outlines the steps to build, sign, and distribute release packages for Android (Signed APK / App Bundle) and iOS (TestFlight / IPA).

---

## 1. Android Release Build

### Prerequisites
- Flutter SDK $\ge 3.10.0$ (`flutter --version`)
- Android SDK $\ge 34$ & Java JDK 17
- Keystore file for release signing (or debug key for testing)

### Automated APK Compilation
Run the automated build script from the `app/` directory:
```powershell
cd app
powershell -ExecutionPolicy Bypass -File ./build_apk.ps1
```

### Manual Command
```bash
cd app
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

**Output Artifacts**:
- Universal APK: `app/build/app/outputs/flutter-apk/app-release.apk`
- ABI-split APKs (ARM64 / ARMv7 / x86_64): `app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 2. Android App Bundle (Google Play Store)

To generate an optimized `.aab` for Play Console upload:
```bash
cd app
flutter build appbundle --release
```
**Output Artifact**: `app/build/app/outputs/bundle/release/app-release.aab`

---

## 3. iOS TestFlight / Release Build

### Prerequisites
- macOS machine with Xcode $\ge 15$
- Apple Developer Program account
- CocoaPods (`pod --version`)

### Steps
1. Navigate to the `app/ios` directory:
   ```bash
   cd app/ios
   pod install
   ```
2. Build iOS release archive:
   ```bash
   cd ..
   flutter build ipa --release
   ```
3. Open `app/ios/Runner.xcworkspace` in Xcode, configure Signing & Capabilities with your Apple Team ID, and use Xcode Organizer to upload to **Apple TestFlight**.

---

## 4. Backend Server Production Launch

To launch the Sanchari Express backend with MongoDB and demo seed data:
```bash
cd server
npm install
npm run seed:demo
npm start
```

The server will listen at `http://localhost:5000/api/v1` with all REST endpoints active.

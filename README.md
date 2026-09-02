# Sanchari — AI-Powered Travel Companion 🌍✨

Sanchari is an intelligent mobile travel companion designed to help travelers discover places, plan itineraries, stay safe with emergency network integration, connect with friends via realtime location sharing, and get context-aware travel assistance powered by Gemini AI.

---

## Monorepo Structure

```
.
├── app/                  # Flutter Mobile Application (Android + iOS)
│   ├── android/          # Native Android configuration
│   ├── ios/              # Native iOS configuration
│   ├── lib/
│   │   ├── core/         # Network, Theme, Constants, Firebase Wrappers
│   │   ├── features/     # Feature-Driven Clean Architecture modules
│   │   │   ├── auth/     # Authentication & Onboarding (Firebase + MongoDB)
│   │   │   │   ├── data/          # Firebase Auth & REST remote data sources, Repositories
│   │   │   │   ├── domain/        # UserModel, EmergencyContact, TravelerType entities
│   │   │   │   └── presentation/  # Onboarding carousel, Login, Register, OTP, Profile Setup, Dashboard
│   │   │   ├── companion/# AI Companion feature (upcoming)
│   │   │   ├── health/   # System boot and backend connectivity verification
│   │   │   ├── location/ # Realtime location sharing feature (upcoming)
│   │   │   └── trips/    # Itinerary & trip planning feature (upcoming)
│   │   ├── app.dart      # MaterialApp setup & Theme configuration
│   │   └── main.dart     # Entry point & ProviderScope initialization
│   ├── pubspec.yaml      # Flutter dependencies (Riverpod, Dio, Firebase, etc.)
│   └── analysis_options.yaml # Strict linting rules
│
├── server/               # Node.js + Express Backend REST API
│   ├── src/
│   │   ├── api/v1/       # REST API v1
│   │   │   ├── controllers/ # Auth & Health controllers
│   │   │   ├── middlewares/ # Firebase ID token verification & error handlers
│   │   │   └── routes/      # Health & Auth protected routes
│   │   ├── config/       # Environment, MongoDB, Firebase Admin, Google APIs config
│   │   ├── models/       # Mongoose User & EmergencyContact models
│   │   └── app.js        # Express middleware and routing pipeline
│   ├── server.js         # HTTP server entry point & graceful shutdown
│   ├── package.json      # Dependencies and scripts
│   ├── .env.example      # Environment variable template
│   └── .eslintrc.json    # Code quality and style linting
│
└── docs/                 # Documentation & Architecture Notes
    ├── ARCHITECTURE.md   # System design & Clean Architecture documentation
    ├── API_CONTRACT.md   # REST API endpoint specifications
    └── FIREBASE_SETUP.md # Firebase Auth, Firestore & FCM configuration guide
```

---

## Authentication & Onboarding Features

1. **Multi-Factor Firebase Authentication**:
   - Email & Password with strength validation
   - Google Sign-In with automated credential exchange
   - Phone Number OTP verification (with 6-digit PIN input & resend countdown)
   - Developer Mock Login for rapid offline local testing
2. **Onboarding Flow**:
   - 3-slide visual onboarding carousel with smooth page indicator and skip option
   - Profile setup wizard for Name, Home City (with quick city chips), and Preferred Language
   - Visual Traveler Persona selector (Solo Explorer, Backpacker, Family Traveler, Woman Traveler, Luxury & Leisure, Group & Friends)
3. **Emergency Contacts & Safety Integration**:
   - Emergency contacts builder (Name, Phone number, Relationship preset)
   - Stored in MongoDB linked to Firebase UID for the Safety & SOS module
4. **Backend Security**:
   - Protected API routes verified via Firebase Admin JWT middleware

---

## Quick Start Guide

### 1. Server Setup (`/server`)

```bash
cd server
cp .env.example .env     # Configure your MongoDB and Firebase keys
npm install
npm run dev              # Starts dev server on http://localhost:5000
```

To verify the server is running, visit:
[http://localhost:5000/api/v1/health](http://localhost:5000/api/v1/health)

### 2. Mobile App Setup (`/app`)

Ensure Flutter is installed on your machine (`flutter doctor`).

```bash
cd app
flutter pub get
flutter run
```

---

## Documentation Links

- [Architecture & Design Details](file:///docs/ARCHITECTURE.md)
- [API Contract & Endpoints](file:///docs/API_CONTRACT.md)
- [Firebase Setup Instructions](file:///docs/FIREBASE_SETUP.md)

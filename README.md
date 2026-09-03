# Sanchari — AI-Powered Travel Companion 🌍✨

Sanchari is an intelligent mobile travel companion designed to help travelers discover places, plan itineraries, stay connected with friends via realtime location sharing, and get context-aware travel assistance powered by AI.

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
│   │   │   ├── auth/     # Authentication feature (data/domain/presentation)
│   │   │   ├── companion/# AI Companion feature (data/domain/presentation)
│   │   │   ├── health/   # System boot and backend connectivity verification
│   │   │   ├── location/ # Realtime location sharing feature (data/domain/presentation)
│   │   │   └── trips/    # Itinerary & trip planning feature (data/domain/presentation)
│   │   ├── app.dart      # MaterialApp setup & Theme configuration
│   │   └── main.dart     # Entry point & ProviderScope initialization
│   ├── pubspec.yaml      # Flutter dependencies (Riverpod, Dio, Firebase, etc.)
│   └── analysis_options.yaml # Strict linting rules
│
├── server/               # Node.js + Express Backend REST API
│   ├── src/
│   │   ├── api/v1/       # REST API v1 (controllers, routes, middlewares)
│   │   ├── config/       # Environment, MongoDB, Firebase Admin, Google APIs config
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

When the app launches, you will see the **"Hello Sanchari"** screen with an interactive health-check ping tool to test connectivity against the backend.

---

## Architecture Highlights

- **Flutter Clean Architecture**: Modularized by feature (`features/<feature_name>/[data|domain|presentation]`).
- **State Management**: **Flutter Riverpod** for declarative, compile-safe dependency injection and state handling.
- **Backend Architecture**: Layered Express REST API with centralized error handling, Mongoose database lifecycle management, and Firebase Admin SDK token verification.
- **Firebase Wiring**: 
  - **Firebase Auth**: User identity & secure token validation.
  - **Cloud Firestore**: Realtime document sync for location sharing & collaborative trips.
  - **Firebase Cloud Messaging (FCM)**: Push notification pipeline for smart travel alerts.

---

## Documentation Links

- [Architecture & Design Details](file:///c:/Users/ADMIN/OneDrive/Desktop/project/docs/ARCHITECTURE.md)
- [API Contract & Endpoints](file:///c:/Users/ADMIN/OneDrive/Desktop/project/docs/API_CONTRACT.md)
- [Firebase Setup Instructions](file:///c:/Users/ADMIN/OneDrive/Desktop/project/docs/FIREBASE_SETUP.md)

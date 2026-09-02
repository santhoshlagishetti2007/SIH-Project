# Sanchari Architecture Documentation

This document outlines the architecture, design principles, module organization, and communication patterns used across the Sanchari monorepo.

---

## 1. System Topology

```
┌─────────────────────────────────────────────────────────┐
│              Sanchari Flutter Mobile App                │
│ (Presentation Layer -> Domain Layer -> Data Layer)      │
└──────────────┬────────────────────────────┬─────────────┘
               │ HTTPS (REST API)           │ Realtime Sync & Auth
               ▼                            ▼
┌───────────────────────────────┐   ┌─────────────────────────────┐
│  Sanchari Node.js REST API    │   │      Google Firebase        │
│  (Express + Mongoose)         │   │                             │
│  • Auth Token Verification    ├───┤ • Firebase Auth             │
│  • Travel Companion AI (LLM)  │   │ • Cloud Firestore (Realtime)│
│  • MongoDB Persistent Store   │   │ • Cloud Messaging (FCM)     │
└──────────────┬────────────────┘   └─────────────────────────────┘
               │
               ▼
┌───────────────────────────────┐
│     MongoDB Atlas / Local     │
│   (Trips, Profiles, History)  │
└───────────────────────────────┘
```

---

## 2. Flutter Mobile Application Architecture (`/app`)

The Flutter application follows **Feature-First Clean Architecture** principles paired with **Riverpod** for state management and dependency injection.

### Directory Structure & Responsibilities

```
app/lib/
├── app.dart                    # App root widget with theme and routing
├── main.dart                   # Application bootstrap & provider scope
├── core/
│   ├── constants/              # Global constants (endpoints, styling keys)
│   ├── network/                # Dio HTTP client, Interceptors, ApiResult<T>
│   ├── services/               # Firebase Auth, Firestore, FCM service singletons
│   ├── theme/                  # Color palettes, typography, theme data
│   └── utils/                  # Logger, validation, formatters
└── features/                   # Feature-first modules
    ├── health/                 # Health check & connectivity verification
    ├── auth/                   # Authentication & user profile
    ├── companion/              # AI Travel Companion & chat assistant
    ├── trips/                  # Itinerary planner, route suggestions
    └── location/               # Realtime companion location sharing
```

### Clean Architecture Layers (Per Feature)

Each feature module is structured into three isolated layers:

```
features/<feature_name>/
├── domain/                     # Independent of external libraries & Flutter UI
│   ├── models/                 # Pure Dart data entities
│   └── repositories/           # Abstract repository contracts / interfaces
├── data/                       # Implements domain contracts
│   ├── datasources/            # Remote (REST / Firestore) & Local (Cache) data sources
│   ├── models/                 # DTOs with serialization / deserialization logic
│   └── repositories/           # Concrete repository implementations
└── presentation/               # Flutter UI & State Management
    ├── controllers/            # Riverpod StateNotifiers / AsyncNotifiers
    ├── screens/                # Top-level screen widgets
    └── widgets/                # Reusable presentation widgets for the feature
```

---

## 3. Node.js Backend Architecture (`/server`)

The backend is built with **Node.js, Express, and Mongoose**, structured following a modular, controller-service-repository pattern.

### Directory Structure

```
server/
├── server.js                   # Server bootstrap, DB connection, graceful shutdown
├── src/
│   ├── app.js                  # Express middleware pipeline, route registration
│   ├── config/                 # Centralized configuration modules
│   │   ├── env.config.js       # Validated environment variables
│   │   ├── db.config.js        # Mongoose connection & lifecycle manager
│   │   ├── firebase.config.js  # Firebase Admin SDK (Auth, Firestore, FCM)
│   │   └── google.config.js    # Google Maps & Gemini AI configuration
│   └── api/v1/
│       ├── controllers/        # Request handling & HTTP response formatting
│       ├── middlewares/        # Auth verification, rate limiting, error handler
│       ├── models/             # Mongoose schemas & data models
│       ├── routes/             # REST route declarations
│       └── services/           # Business logic & 3rd-party integrations
```

### Key Middleware Flow

1. **Helmet & CORS**: Sets secure HTTP response headers and allows controlled cross-origin requests.
2. **Request Logger (Morgan / Custom)**: Logs incoming method, URL, status code, and latency.
3. **Authentication Middleware (`auth.middleware.js`)**: Decodes and verifies Firebase ID Tokens (`Bearer <token>`) using `firebase-admin.auth()`.
4. **Validation**: Validates incoming payload shapes.
5. **Centralized Error Handler (`error.middleware.js`)**: Converts application exceptions into uniform API response envelopes.

---

## 4. Firebase Integration Strategy

| Feature | Firebase Service | Client Role (`/app`) | Server Role (`/server`) |
| :--- | :--- | :--- | :--- |
| **Authentication** | Firebase Auth | Sign-in (Google/Email), token refresh | Verifies JWT tokens on protected REST routes |
| **Realtime Sharing** | Cloud Firestore | Listens to live location feeds & trip coordinates | Server sync & administrative access |
| **Push Alerts** | Cloud Messaging (FCM) | Receives background travel alerts & warnings | Sends targeted/topic notifications via Admin SDK |

---

## 5. Security & Environment Configuration

- All secrets (MongoDB URI, Firebase Private Keys, API Keys) are loaded exclusively via environment variables (`dotenv`).
- `.env.example` provides default configuration keys without exposing credentials.
- In production, Firebase credentials can be supplied as individual environment variables or loaded from a secure vault / service account path.

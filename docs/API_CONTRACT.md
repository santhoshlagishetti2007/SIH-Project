# Sanchari REST API Contract

This document provides the canonical specification for the Sanchari REST API endpoints.

**Base URL**: `http://<host>:<port>/api/v1`  
**Default Local URL**: `http://localhost:5000/api/v1`  
**Android Emulator Localhost**: `http://10.0.2.2:5000/api/v1`

---

## Authentication Header

Protected endpoints require a Firebase ID Token in the standard HTTP `Authorization` header:

```http
Authorization: Bearer <firebase_id_token>
```

*For local testing in development mode, `mock-dev-token` or `dev-token-<uid>` is accepted when Firebase Admin credentials are not yet configured.*

---

## Standard Response Format

All API responses follow a consistent envelope structure:

### Success Response (`2xx`)
```json
{
  "success": true,
  "message": "Human-readable status or operation summary",
  "data": { ... },
  "timestamp": "2026-09-02T15:00:00.000Z"
}
```

### Error Response (`4xx` / `5xx`)
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE_ENUM",
    "message": "Detailed error message",
    "details": null
  },
  "timestamp": "2026-09-02T15:00:00.000Z"
}
```

---

## 1. System Health Check

Returns the operational status of the server, MongoDB database connectivity, and Firebase Admin SDK state.

- **Method**: `GET`
- **Path**: `/health`
- **Full URL**: `/api/v1/health`
- **Auth Required**: No

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Sanchari API is healthy",
  "data": {
    "service": "sanchari-backend",
    "version": "1.0.0",
    "status": "healthy",
    "uptimeSeconds": 142.5,
    "environment": "development",
    "services": {
      "database": {
        "status": "connected",
        "readyState": 1
      },
      "firebase": {
        "status": "initialized",
        "projectId": "sanchari-dev"
      }
    }
  },
  "timestamp": "2026-09-02T15:00:00.000Z"
}
```

---

## 2. Authentication & User Profile Endpoints (`/api/v1/auth`)

All routes under `/api/v1/auth/*` are protected with Firebase ID token verification middleware.

### 2.1 Sync Firebase User Profile
Idempotently creates or updates the user profile in MongoDB matching the Firebase UID.

- **Method**: `POST`
- **Path**: `/auth/sync-profile`
- **Auth Required**: Yes (`Bearer <token>`)

#### Request Body
```json
{
  "email": "aarav@example.com",
  "displayName": "Aarav Sharma",
  "photoUrl": "https://example.com/avatar.jpg",
  "homeCity": "Mumbai",
  "preferredLanguage": "hi",
  "travelerType": "solo",
  "isOnboarded": false
}
```

#### Response (`200 OK` or `201 Created`)
```json
{
  "success": true,
  "message": "User profile synchronized successfully",
  "data": {
    "uid": "FIREBASE_UID_123",
    "email": "aarav@example.com",
    "displayName": "Aarav Sharma",
    "phone": null,
    "photoUrl": "https://example.com/avatar.jpg",
    "homeCity": "Mumbai",
    "preferredLanguage": "hi",
    "travelerType": "solo",
    "emergencyContacts": [],
    "isOnboarded": false,
    "authProvider": "password",
    "travelPreferences": [],
    "createdAt": "2026-09-02T15:10:00.000Z",
    "updatedAt": "2026-09-02T15:10:00.000Z"
  },
  "timestamp": "2026-09-02T15:10:00.000Z"
}
```

---

### 2.2 Get Current User Profile
Retrieves the full profile, traveler type, and emergency contacts for the authenticated user.

- **Method**: `GET`
- **Path**: `/auth/me`
- **Auth Required**: Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "User profile fetched successfully",
  "data": {
    "uid": "FIREBASE_UID_123",
    "email": "aarav@example.com",
    "displayName": "Aarav Sharma",
    "homeCity": "Mumbai",
    "preferredLanguage": "hi",
    "travelerType": "solo",
    "emergencyContacts": [
      {
        "_id": "66d5b0...",
        "name": "Sunita Sharma",
        "phone": "+919876543210",
        "relation": "parent",
        "isPrimary": true
      }
    ],
    "isOnboarded": true,
    "authProvider": "password"
  },
  "timestamp": "2026-09-02T15:15:00.000Z"
}
```

---

### 2.3 Update Profile & Onboarding Settings
Updates personalization details such as home city, traveler type persona, and preferred language.

- **Method**: `PUT`
- **Path**: `/auth/profile`
- **Auth Required**: Yes (`Bearer <token>`)

#### Request Body
```json
{
  "displayName": "Aarav Sharma",
  "homeCity": "Bengaluru",
  "preferredLanguage": "en",
  "travelerType": "backpacker",
  "isOnboarded": true
}
```

#### Valid `travelerType` Options:
- `solo`
- `backpacker`
- `family`
- `woman_traveler`
- `luxury`
- `group`
- `other`

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "uid": "FIREBASE_UID_123",
    "displayName": "Aarav Sharma",
    "homeCity": "Bengaluru",
    "preferredLanguage": "en",
    "travelerType": "backpacker",
    "isOnboarded": true
  },
  "timestamp": "2026-09-02T15:20:00.000Z"
}
```

---

### 2.4 Get Emergency Contacts
Retrieves the user's safety contacts list.

- **Method**: `GET`
- **Path**: `/auth/emergency-contacts`
- **Auth Required**: Yes (`Bearer <token>`)

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Emergency contacts retrieved successfully",
  "data": [
    {
      "_id": "66d5b001...",
      "name": "Sunita Sharma",
      "phone": "+919876543210",
      "relation": "parent",
      "isPrimary": true
    }
  ],
  "timestamp": "2026-09-02T15:25:00.000Z"
}
```

---

### 2.5 Batch Set Emergency Contacts
Replaces or sets the emergency contact list during onboarding or settings.

- **Method**: `PUT`
- **Path**: `/auth/emergency-contacts`
- **Auth Required**: Yes (`Bearer <token>`)

#### Request Body
```json
{
  "contacts": [
    {
      "name": "Sunita Sharma",
      "phone": "+919876543210",
      "relation": "parent",
      "isPrimary": true
    },
    {
      "name": "Vikram Sen",
      "phone": "+919123456780",
      "relation": "friend",
      "isPrimary": false
    }
  ]
}
```

#### Response (`200 OK`)
```json
{
  "success": true,
  "message": "Emergency contacts updated successfully",
  "data": [
    {
      "_id": "66d5b001...",
      "name": "Sunita Sharma",
      "phone": "+919876543210",
      "relation": "parent",
      "isPrimary": true
    },
    {
      "_id": "66d5b002...",
      "name": "Vikram Sen",
      "phone": "+919123456780",
      "relation": "friend",
      "isPrimary": false
    }
  ],
  "timestamp": "2026-09-02T15:25:00.000Z"
}
```

---

### 2.6 Add Single Emergency Contact
- **Method**: `POST`
- **Path**: `/auth/emergency-contacts`
- **Auth Required**: Yes (`Bearer <token>`)

#### Request Body
```json
{
  "name": "Vikram Sen",
  "phone": "+919123456780",
  "relation": "friend",
  "isPrimary": false
}
```

---

### 2.7 Delete Emergency Contact
- **Method**: `DELETE`
- **Path**: `/auth/emergency-contacts/:contactId`
- **Auth Required**: Yes (`Bearer <token>`)

---

## Planned API Roadmap (v1)

### AI Travel Companion (`/api/v1/companion`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/companion/chat` | Send conversational query to Gemini AI travel companion | Bearer Token |
| `POST` | `/companion/recommendations` | Get personalized place / activity recommendations based on `travelerType` | Bearer Token |

### Trips & Itineraries (`/api/v1/trips`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/trips` | List all trips for current user | Bearer Token |
| `POST` | `/trips` | Create a new trip itinerary | Bearer Token |
| `GET` | `/trips/:id` | Get full trip details with day-by-day itinerary | Bearer Token |
| `PATCH` | `/trips/:id` | Update itinerary items | Bearer Token |

### Notifications & Location (`/api/v1/notifications`, `/api/v1/location`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/notifications/register-token` | Register FCM push notification token | Bearer Token |
| `POST` | `/location/share-session` | Create/join realtime companion sharing session | Bearer Token |

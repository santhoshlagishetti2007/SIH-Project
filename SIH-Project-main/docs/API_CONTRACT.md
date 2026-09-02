# Sanchari REST API Contract

This document provides the canonical specification for the Sanchari REST API endpoints.

**Base URL**: `http://<host>:<port>/api/v1`  
**Default Local URL**: `http://localhost:5000/api/v1`  
**Android Emulator Localhost**: `http://10.0.2.2:5000/api/v1`

---

## Standard Response Format

All API responses follow a consistent envelope structure:

### Success Response (`2xx`)
```json
{
  "success": true,
  "message": "Human-readable status or operation summary",
  "data": { ... },
  "timestamp": "2026-09-01T15:00:00.000Z"
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
  "timestamp": "2026-09-01T15:00:00.000Z"
}
```

---

## Endpoints

### 1. System Health Check

Returns the operational status of the server, MongoDB database connectivity, and Firebase Admin SDK state.

- **Method**: `GET`
- **Path**: `/health`
- **Full URL**: `/api/v1/health`
- **Auth Required**: No

#### Request
```http
GET /api/v1/health HTTP/1.1
Host: localhost:5000
Accept: application/json
```

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
  "timestamp": "2026-09-01T15:00:00.000Z"
}
```

---

## Planned API Roadmap (v1)

### Authentication & Profile (`/api/v1/auth`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/auth/sync-profile` | Synchronize Firebase Auth user with MongoDB profile | Bearer Token |
| `GET` | `/auth/me` | Fetch authenticated user profile and preferences | Bearer Token |

### AI Travel Companion (`/api/v1/companion`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/companion/chat` | Send conversational query to Gemini AI travel companion | Bearer Token |
| `POST` | `/companion/recommendations` | Get personalized place / activity recommendations | Bearer Token |

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

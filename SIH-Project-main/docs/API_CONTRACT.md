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
| `GET` | `/trips` | List all trips for current user (auto-seeds sample if empty) | Bearer Token |
| `POST` | `/trips` | Create a new trip itinerary | Bearer Token |
| `GET` | `/trips/:id` | Get full trip details with day-by-day itinerary and transit legs | Bearer Token |
| `PATCH` | `/trips/:id/itinerary` | Update and persist editable itinerary & recalculate total costs | Bearer Token |
| `GET` | `/trips/places/alternatives` | Get 3 similar alternatives matching category via Places API | Bearer Token |
| `GET` | `/trips/places/autocomplete` | Live search places via Google Places Autocomplete | Bearer Token |
| `GET` | `/trips/places/eat-nearby` | Get 3 authentic local eateries near stop coordinates (24h TTL cache) | Bearer Token |
| `POST` | `/trips/transport/calculate-legs` | Calculate distance, duration, and multi-modal transit costs | Bearer Token |

### Admin Transport Rate Configuration (`/api/v1/admin/transport-rates`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/admin/transport-rates` | List all configured city transport rate tables | Bearer Token |
| `GET` | `/admin/transport-rates/:city` | Get transport rates for a specific city | Bearer Token |
| `PUT` | `/admin/transport-rates/:city` | Create / update per-km rates & base fares stored in MongoDB | Bearer Token |
| `POST` | `/admin/transport-rates/reset-defaults` | Reset all rate tables to default seed values | Bearer Token |

### Live Translate & Voice AI (`/api/v1/translate`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/translate/live-exchange` | Unified one-shot pipeline (STT speech $\rightarrow$ Cloud Translation $\rightarrow$ TTS speech) | Bearer Token |
| `POST` | `/translate/translate-text` | Translate text with pronunciation transliteration | Bearer Token |
| `POST` | `/translate/speech-to-text` | Transcribe voice audio via Google Cloud STT | Bearer Token |
| `POST` | `/translate/text-to-speech` | Synthesize natural voice audio via Google Cloud TTS | Bearer Token |
| `GET` | `/translate/phrasebook` | Get categorized offline travel phrasebook with phonetics | Bearer Token |

### Local Finds Marketplace (`/api/v1/marketplace`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `GET` | `/marketplace/finds` | Query local artisan listings with city, category, and search filters | Public / Bearer Token |
| `GET` | `/marketplace/finds/:id` | Get single product listing with artisan story and vendor contact details | Public / Bearer Token |
| `POST` | `/marketplace/finds` | Publish new artisan product listing (Web Admin / Artisan) | Bearer Token |
| `PUT` | `/marketplace/finds/:id` | Update artisan product listing | Bearer Token |
| `DELETE` | `/marketplace/finds/:id` | Delete vendor listing | Bearer Token |
| `POST` | `/marketplace/finds/seed-defaults` | Restore default regional artisan product catalog | Bearer Token |

### Safety & Live Location Sharing (`/api/v1/safety`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/safety/sos-trigger` | Trigger emergency SOS alert & broadcast live tracking link | Bearer Token / Anonymous |
| `POST` | `/safety/share-trip/start` | Start live trip location sharing session | Bearer Token |
| `POST` | `/safety/share-trip/update` | Push periodic real-time GPS coordinate ping | Bearer Token |
| `POST` | `/safety/share-trip/stop` | Stop active tracking session | Bearer Token |
| `GET` | `/safety/session/:sessionId` | Retrieve live tracking data for public web viewer (`/live-track/:id`) | Public |

### Notifications & Location (`/api/v1/notifications`, `/api/v1/location`)
| Method | Endpoint | Description | Auth |
| :--- | :--- | :--- | :--- |
| `POST` | `/notifications/register-token` | Register FCM push notification token | Bearer Token |
| `POST` | `/location/share-session` | Create/join realtime companion sharing session | Bearer Token |

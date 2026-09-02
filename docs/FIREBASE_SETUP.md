# Firebase Setup Guide for Sanchari

This guide details how to configure Firebase for both the **Flutter Mobile App (`/app`)** and the **Node.js Backend (`/server`)**.

---

## 1. Firebase Console Project Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project named **Sanchari** (or `sanchari-dev`).
2. Enable the following Firebase services:
   - **Authentication**: Enable Email/Password and Google Sign-In.
   - **Cloud Firestore**: Create a Firestore database in Native mode.
   - **Cloud Messaging (FCM)**: Enable FCM for notifications.

---

## 2. Server Configuration (`/server`)

The backend uses the **Firebase Admin SDK** to verify ID tokens, send push notifications via FCM, and interact with Firestore.

### Obtaining the Service Account Key:
1. In Firebase Console, navigate to **Project Settings > Service accounts**.
2. Click **Generate new private key** and download the JSON file.
3. You can configure the credentials in `/server/.env` using one of two methods:

#### Method A: Direct Environment Variables (Recommended for Deployment)
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgk...-----END PRIVATE KEY-----\n"
```

#### Method B: Service Account JSON File Path
```env
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/serviceAccountKey.json
```

---

## 3. Flutter App Configuration (`/app`)

### Android Setup
1. In Firebase Console, add an **Android App** with package name `com.sanchari.app`.
2. Download `google-services.json` and place it in:
   `app/android/app/google-services.json`
3. The Gradle build scripts are pre-configured to apply the `com.google.gms.google-services` plugin.

### iOS Setup
1. In Firebase Console, add an **iOS App** with bundle identifier `com.sanchari.app`.
2. Download `GoogleService-Info.plist` and place it in:
   `app/ios/Runner/GoogleService-Info.plist`

### Using FlutterFire CLI (Alternative)
You can also automatically configure FlutterFire:
```bash
dart pub global activate flutterfire_cli
cd app
flutterfire configure --project=your-project-id
```

---

## 4. Firestore Security Rules (Starter)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write only their own user profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Realtime location sessions: accessible to authenticated group members
    match /location_sessions/{sessionId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

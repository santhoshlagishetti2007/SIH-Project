const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
const envConfig = require('./env.config');

let firebaseApp = null;
let isInitialized = false;

/**
 * Initialize Firebase Admin SDK
 */
const initFirebase = () => {
  if (admin.apps.length > 0) {
    firebaseApp = admin.app();
    isInitialized = true;
    return firebaseApp;
  }

  try {
    const { projectId, clientEmail, privateKey, serviceAccountPath, databaseURL } = envConfig.firebase;

    // Check for service account file
    if (serviceAccountPath) {
      const resolvedPath = path.resolve(__dirname, '../../', serviceAccountPath);
      if (fs.existsSync(resolvedPath)) {
        const serviceAccount = require(resolvedPath);
        firebaseApp = admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          databaseURL,
        });
        isInitialized = true;
        console.log(`[Firebase] Initialized with service account file: ${resolvedPath}`);
        return firebaseApp;
      }
    }

    // Check for explicit environment credentials
    if (projectId && clientEmail && privateKey && !privateKey.includes('placeholder') && !privateKey.includes('example')) {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey,
        }),
        databaseURL,
      });
      isInitialized = true;
      console.log(`[Firebase] Initialized with environment credentials for project: ${projectId}`);
      return firebaseApp;
    }

    console.warn('[Firebase] Firebase Admin credentials not fully configured. Operating in stub/dev mode.');
    isInitialized = false;
  } catch (error) {
    console.warn(`[Firebase] Firebase initialization error: ${error.message}`);
    isInitialized = false;
  }

  return null;
};

/**
 * Get Firebase Auth instance
 */
const getFirebaseAuth = () => {
  if (!isInitialized) return null;
  return admin.auth();
};

/**
 * Get Cloud Firestore instance
 */
const getFirestore = () => {
  if (!isInitialized) return null;
  return admin.firestore();
};

/**
 * Get Firebase Cloud Messaging (FCM) instance
 */
const getMessaging = () => {
  if (!isInitialized) return null;
  return admin.messaging();
};

/**
 * Get current Firebase status
 */
const getFirebaseState = () => {
  return {
    status: isInitialized ? 'initialized' : 'unconfigured',
    projectId: envConfig.firebase.projectId || null,
  };
};

module.exports = {
  initFirebase,
  getFirebaseAuth,
  getFirestore,
  getMessaging,
  getFirebaseState,
};

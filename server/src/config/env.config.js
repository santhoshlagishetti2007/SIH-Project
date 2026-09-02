const dotenv = require('dotenv');
const path = require('path');

// Load .env file from server root
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const envConfig = {
  // Server
  port: parseInt(process.env.PORT, 10) || 5000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',
  isDevelopment: process.env.NODE_ENV === 'development',
  apiPrefix: process.env.API_PREFIX || '/api/v1',
  corsOrigin: process.env.CORS_ORIGIN || '*',

  // MongoDB
  mongodb: {
    uri: process.env.MONGODB_URI || 'mongodb://localhost:27017/sanchari',
    options: {
      serverSelectionTimeoutMS: 5000,
      autoIndex: process.env.NODE_ENV !== 'production',
    },
  },

  // Firebase Admin SDK
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || 'sanchari-dev',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY
      ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
      : undefined,
    databaseURL: process.env.FIREBASE_DATABASE_URL,
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH,
  },

  // Google APIs & Gemini
  google: {
    mapsApiKey: process.env.GOOGLE_MAPS_API_KEY,
    geminiApiKey: process.env.GEMINI_API_KEY,
  },
};

module.exports = envConfig;

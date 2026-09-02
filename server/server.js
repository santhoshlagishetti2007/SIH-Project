const http = require('http');
const app = require('./src/app');
const envConfig = require('./src/config/env.config');
const { connectDatabase, disconnectDatabase } = require('./src/config/db.config');
const { initFirebase } = require('./src/config/firebase.config');
const { initGeminiClient } = require('./src/config/google.config');

const server = http.createServer(app);

/**
 * Bootstrap Sanchari Server
 */
const startServer = async () => {
  console.log('====================================================');
  console.log('       Starting Sanchari Backend API Server         ');
  console.log('====================================================');

  // Initialize Firebase Admin SDK
  initFirebase();

  // Initialize Gemini AI Client
  initGeminiClient();

  // Connect to MongoDB
  await connectDatabase();

  // Start HTTP Listener
  server.listen(envConfig.port, () => {
    console.log(`[Server] Listening on http://localhost:${envConfig.port}`);
    console.log(`[Server] Health route available at: http://localhost:${envConfig.port}${envConfig.apiPrefix}/health`);
    console.log(`[Server] Environment: ${envConfig.nodeEnv}`);
  });
};

/**
 * Graceful Shutdown Handler
 */
const handleShutdown = async (signal) => {
  console.log(`\n[Server] Received ${signal}. Starting graceful shutdown...`);

  server.close(async () => {
    console.log('[Server] HTTP server closed.');
    await disconnectDatabase();
    console.log('[Server] Shutdown completed cleanly. Exiting.');
    process.exit(0);
  });

  // Force close after 10s timeout
  setTimeout(() => {
    console.error('[Server] Forced termination after timeout.');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => handleShutdown('SIGTERM'));
process.on('SIGINT', () => handleShutdown('SIGINT'));

process.on('unhandledRejection', (reason, promise) => {
  console.error('[Server] Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('[Server] Uncaught Exception:', error);
  process.exit(1);
});

startServer();

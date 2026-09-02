const { getDatabaseState } = require('../../../config/db.config');
const { getFirebaseState } = require('../../../config/firebase.config');
const { getGoogleAIState } = require('../../../config/google.config');

const serverStartTime = Date.now();

/**
 * Controller handling health checks
 */
const getHealthStatus = (req, res) => {
  const dbState = getDatabaseState();
  const firebaseState = getFirebaseState();
  const googleState = getGoogleAIState();

  const uptimeSeconds = Math.floor((Date.now() - serverStartTime) / 1000);

  const healthData = {
    service: 'sanchari-backend',
    version: '1.0.0',
    status: 'healthy',
    uptimeSeconds,
    uptimeHuman: `${Math.floor(uptimeSeconds / 60)}m ${uptimeSeconds % 60}s`,
    environment: process.env.NODE_ENV || 'development',
    serverTime: new Date().toISOString(),
    services: {
      database: dbState,
      firebase: firebaseState,
      googleAI: googleState,
    },
  };

  res.status(200).json({
    success: true,
    message: 'Sanchari backend API is running smoothly.',
    data: healthData,
    timestamp: new Date().toISOString(),
  });
};

module.exports = {
  getHealthStatus,
};

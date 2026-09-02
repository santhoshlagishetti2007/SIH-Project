const mongoose = require('mongoose');
const envConfig = require('./env.config');

let isConnected = false;

/**
 * Connect to MongoDB database via Mongoose
 */
const connectDatabase = async () => {
  if (isConnected) {
    console.log('[Database] MongoDB is already connected.');
    return;
  }

  try {
    const conn = await mongoose.connect(envConfig.mongodb.uri, envConfig.mongodb.options);
    isConnected = !!conn.connections[0].readyState;
    console.log(`[Database] MongoDB Connected: ${conn.connection.host}/${conn.connection.name}`);
  } catch (error) {
    console.warn(`[Database] MongoDB connection failed: ${error.message}`);
    console.warn('[Database] Running in disconnected DB mode. Health check will report DB offline.');
    isConnected = false;
  }
};

/**
 * Disconnect from MongoDB
 */
const disconnectDatabase = async () => {
  if (!isConnected) return;
  try {
    await mongoose.disconnect();
    isConnected = false;
    console.log('[Database] MongoDB disconnected cleanly.');
  } catch (error) {
    console.error(`[Database] Error during disconnect: ${error.message}`);
  }
};

/**
 * Get current database connection state
 */
const getDatabaseState = () => {
  const states = {
    0: 'disconnected',
    1: 'connected',
    2: 'connecting',
    3: 'disconnecting',
    99: 'uninitialized',
  };
  const readyState = mongoose.connection ? mongoose.connection.readyState : 0;
  return {
    status: states[readyState] || 'unknown',
    readyState,
    host: mongoose.connection?.host || null,
    name: mongoose.connection?.name || null,
  };
};

module.exports = {
  connectDatabase,
  disconnectDatabase,
  getDatabaseState,
};

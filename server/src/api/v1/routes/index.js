const express = require('express');
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');

const router = express.Router();

// Mount v1 resource routes
router.use('/health', healthRoutes);
router.use('/auth', authRoutes);

// Root v1 index route
router.get('/', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to Sanchari AI Travel Companion API v1',
    version: '1.0.0',
    docs: '/docs/API_CONTRACT.md',
    endpoints: {
      health: '/api/v1/health',
      auth: {
        syncProfile: 'POST /api/v1/auth/sync-profile',
        getProfile: 'GET /api/v1/auth/me',
        updateProfile: 'PUT /api/v1/auth/profile',
        emergencyContacts: 'GET|PUT|POST|DELETE /api/v1/auth/emergency-contacts',
      },
      companion: '/api/v1/companion (upcoming)',
      trips: '/api/v1/trips (upcoming)',
      location: '/api/v1/location (upcoming)',
    },
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;

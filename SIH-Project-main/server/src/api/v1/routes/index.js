const express = require('express');
const healthRoutes = require('./health.routes');
const authRoutes = require('./auth.routes');
const tripRoutes = require('./trip.routes');
const adminRoutes = require('./admin.routes');
const translateRoutes = require('./translate.routes');
const marketplaceRoutes = require('./marketplace.routes');
const safetyRoutes = require('./safety.routes');

const router = express.Router();

// Mount v1 resource routes
router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/trips', tripRoutes);
router.use('/admin', adminRoutes);
router.use('/translate', translateRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/safety', safetyRoutes);

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
      },
      trips: {
        list: 'GET /api/v1/trips',
        getById: 'GET /api/v1/trips/:id',
        updateItinerary: 'PATCH /api/v1/trips/:id/itinerary',
        placesAlternatives: 'GET /api/v1/trips/places/alternatives',
        placesAutocomplete: 'GET /api/v1/trips/places/autocomplete',
        calculateTransit: 'POST /api/v1/trips/transport/calculate-legs',
      },
      admin: {
        transportRates: 'GET|PUT /api/v1/admin/transport-rates',
      },
    },
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;

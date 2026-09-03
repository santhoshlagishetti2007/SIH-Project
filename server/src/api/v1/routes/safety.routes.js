const express = require('express');
const safetyController = require('../controllers/safety.controller');

const router = express.Router();

// SOS Trigger & Management
router.post('/sos-trigger', safetyController.triggerSos);

// Live Trip Location Sharing
router.post('/share-trip/start', safetyController.startTripShare);
router.post('/share-trip/update', safetyController.updateLiveLocation);
router.post('/share-trip/stop', safetyController.stopSession);

// Public session retrieval for Web Tracker
router.get('/session/:sessionId', safetyController.getSession);

module.exports = router;

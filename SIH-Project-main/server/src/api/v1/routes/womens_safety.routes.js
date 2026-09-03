const express = require('express');
const womensSafetyController = require('../controllers/womens_safety.controller');

const router = express.Router();

// Destination safety guides
router.get('/guide/:city', womensSafetyController.getCitySafetyGuide);
router.put('/guide/:city', womensSafetyController.updateCitySafetyGuide);

// Nearest emergency points (police/hospital)
router.get('/emergency-nearby', womensSafetyController.getNearestEmergencyServices);

// Women-verified stays and guides
router.get('/verified-stays-guides', womensSafetyController.getWomenVerifiedStaysAndGuides);

module.exports = router;

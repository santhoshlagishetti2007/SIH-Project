const express = require('express');
const adminController = require('../controllers/admin.controller');
const { verifyAuth } = require('../middlewares/auth.middleware');

const router = express.Router();

// Apply auth middleware
router.use(verifyAuth);

// Admin Transport Rate Configuration Endpoints
router.get('/transport-rates', adminController.getTransportRates);
router.get('/transport-rates/:city', adminController.getTransportRatesByCity);
router.put('/transport-rates/:city', adminController.updateTransportRatesByCity);
router.post('/transport-rates/reset-defaults', adminController.resetDefaultRates);

module.exports = router;

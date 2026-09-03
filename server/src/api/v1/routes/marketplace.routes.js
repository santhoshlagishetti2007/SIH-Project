const express = require('express');
const marketplaceController = require('../controllers/marketplace.controller');

const router = express.Router();

// Public / Traveler browsing endpoints
router.get('/finds', marketplaceController.getListings);
router.get('/finds/:id', marketplaceController.getListingById);

// Vendor & Admin listing management endpoints
router.post('/finds', marketplaceController.createListing);
router.put('/finds/:id', marketplaceController.updateListing);
router.delete('/finds/:id', marketplaceController.deleteListing);
router.post('/finds/seed-defaults', marketplaceController.seedDefaults);

module.exports = router;

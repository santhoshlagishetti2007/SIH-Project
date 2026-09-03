const express = require('express');
const tripController = require('../controllers/trip.controller');
const { verifyAuth } = require('../middlewares/auth.middleware');

const router = express.Router();

// Apply auth middleware to all trip endpoints
router.use(verifyAuth);

// Places exploration & helper endpoints
router.get('/places/alternatives', tripController.getSwapAlternatives);
router.get('/places/autocomplete', tripController.placesAutocomplete);
router.get('/places/eat-nearby', tripController.getEatNearby);

// Transport calculation endpoint
router.post('/transport/calculate-legs', tripController.calculateTransitLegs);

// Trip collection endpoints
router.get('/', tripController.getMyTrips);
router.post('/', tripController.createTrip);

// Specific Trip endpoints
router.get('/:tripId', tripController.getTripById);
router.patch('/:tripId/itinerary', tripController.updateTripItinerary);
router.patch('/:tripId', tripController.updateTripItinerary);
router.delete('/:tripId', tripController.deleteTrip);

module.exports = router;

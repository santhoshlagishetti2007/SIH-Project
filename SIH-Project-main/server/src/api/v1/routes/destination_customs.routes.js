const express = require('express');
const destinationCustomsController = require('../controllers/destination_customs.controller');

const router = express.Router();

router.get('/customs', destinationCustomsController.getAllDestinations);
router.get('/customs/:destination', destinationCustomsController.getDestinationCustoms);
router.put('/customs/:destination', destinationCustomsController.updateDestinationCustoms);

module.exports = router;

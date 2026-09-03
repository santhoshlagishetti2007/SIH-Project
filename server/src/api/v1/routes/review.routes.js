const express = require('express');
const reviewController = require('../controllers/review.controller');

const router = express.Router();

router.get('/', reviewController.getReviews);
router.post('/', reviewController.createReview);
router.post('/:id/report', reviewController.reportReview);
router.patch('/:id/moderate', reviewController.moderateReview);

module.exports = router;

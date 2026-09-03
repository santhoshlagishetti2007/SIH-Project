const reviewService = require('../../../services/review.service');

const reviewController = {
  /**
   * Get reviews and rating metrics for a target
   * GET /api/v1/reviews?targetId=...&targetType=...
   */
  async getReviews(req, res, next) {
    try {
      const { targetId, targetType, includeHidden } = req.query;

      const result = await reviewService.getReviews({
        targetId: targetId || '',
        targetType: targetType || '',
        includeHidden: includeHidden === 'true',
      });

      return res.status(200).json({
        success: true,
        message: 'Reviews retrieved successfully',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Submit new review
   * POST /api/v1/reviews
   */
  async createReview(req, res, next) {
    try {
      const { targetType, targetId, userId, userName, userAvatar, rating, text, photos } = req.body;

      if (!targetId || !text) {
        return res.status(400).json({
          success: false,
          message: 'targetId and text are required',
          timestamp: new Date().toISOString(),
        });
      }

      const review = await reviewService.createReview({
        targetType: targetType || 'place',
        targetId,
        userId: userId || req.user?.uid || 'anonymous_traveler',
        userName: userName || req.user?.displayName || 'Traveler',
        userAvatar: userAvatar || '',
        rating: rating !== undefined ? parseFloat(rating) : 5,
        text,
        photos: photos || [],
      });

      return res.status(201).json({
        success: true,
        message: 'Review submitted successfully',
        data: review,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Report review for abuse
   * POST /api/v1/reviews/:id/report
   */
  async reportReview(req, res, next) {
    try {
      const { id } = req.params;
      const { userId, reason } = req.body;

      const result = await reviewService.reportReview(id, {
        userId: userId || req.user?.uid || 'traveler_reviewer',
        reason: reason || 'inappropriate_content',
      });

      return res.status(200).json({
        success: true,
        message: result.message,
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },

  /**
   * Admin moderation
   * PATCH /api/v1/reviews/:id/moderate
   */
  async moderateReview(req, res, next) {
    try {
      const { id } = req.params;
      const { action } = req.body;

      const result = await reviewService.adminModerateReview(id, {
        action: action || 'approve',
      });

      return res.status(200).json({
        success: true,
        message: result.message || 'Review moderation updated',
        data: result,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = reviewController;

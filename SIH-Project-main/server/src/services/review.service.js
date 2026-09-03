const mongoose = require('mongoose');
const Review = require('../models/review.model');

const REPORT_HIDE_THRESHOLD = 3;

class ReviewService {
  constructor() {
    this._inMemoryReviews = Review.getSeedData().map((r, idx) => ({
      id: `rev_${idx + 1}`,
      _id: `rev_${idx + 1}`,
      ...r,
      reportedBy: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  }

  /**
   * Get reviews and computed rating metrics for a target
   */
  async getReviews({ targetId, targetType, includeHidden = false } = {}) {
    let reviewsList = [];

    if (mongoose.connection.readyState === 1) {
      try {
        const count = await Review.countDocuments();
        if (count === 0) {
          await Review.insertMany(Review.getSeedData());
        }

        const query = {};
        if (targetId) query.targetId = targetId;
        if (targetType) query.targetType = targetType;
        if (!includeHidden) query.isHidden = false;

        reviewsList = await Review.find(query).sort({ createdAt: -1 });
      } catch (err) {
        console.warn(`[ReviewService] MongoDB getReviews error: ${err.message}`);
      }
    }

    if (reviewsList.length === 0 && this._inMemoryReviews.length > 0) {
      reviewsList = this._inMemoryReviews.filter((r) => {
        if (targetId && r.targetId !== targetId) return false;
        if (targetType && r.targetType !== targetType) return false;
        if (!includeHidden && r.isHidden) return false;
        return true;
      });
    }

    // Compute Metrics: Average Rating & Distribution
    const totalReviews = reviewsList.length;
    let sumRating = 0;
    const ratingBreakdown = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };

    reviewsList.forEach((r) => {
      const score = Math.min(5, Math.max(1, Math.round(r.rating || 5)));
      sumRating += r.rating || 5;
      ratingBreakdown[score] = (ratingBreakdown[score] || 0) + 1;
    });

    const averageRating = totalReviews > 0 ? parseFloat((sumRating / totalReviews).toFixed(1)) : 0.0;

    return {
      targetId: targetId || 'all',
      targetType: targetType || 'all',
      averageRating,
      totalReviews,
      ratingBreakdown,
      reviews: reviewsList,
    };
  }

  /**
   * Submit a new review
   */
  async createReview({
    targetType = 'place',
    targetId,
    userId = 'guest_traveler',
    userName = 'Traveler',
    userAvatar = '',
    rating = 5,
    text,
    photos = [],
  }) {
    if (!targetId || !text) {
      throw new Error('targetId and text are required');
    }

    const numRating = Math.min(5, Math.max(1, parseFloat(rating) || 5));

    const reviewData = {
      targetType,
      targetId,
      userId,
      userName,
      userAvatar,
      rating: numRating,
      text: text.trim(),
      photos: Array.isArray(photos) ? photos : [],
      reportCount: 0,
      reportedBy: [],
      isHidden: false,
      moderationStatus: 'approved',
    };

    if (mongoose.connection.readyState === 1) {
      try {
        const doc = new Review(reviewData);
        return await doc.save();
      } catch (err) {
        console.warn(`[ReviewService] MongoDB createReview error: ${err.message}`);
      }
    }

    const inMem = {
      id: `rev_${Date.now()}`,
      _id: `rev_${Date.now()}`,
      ...reviewData,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this._inMemoryReviews.unshift(inMem);
    return inMem;
  }

  /**
   * Report a review for abuse/spam. Auto-hides when reports reach threshold (3).
   */
  async reportReview(reviewId, { userId = 'anonymous', reason: _reason = 'inappropriate' } = {}) {
    let review = null;

    if (mongoose.connection.readyState === 1) {
      try {
        if (mongoose.isValidObjectId(reviewId)) {
          review = await Review.findById(reviewId);
          if (review) {
            if (!review.reportedBy.includes(userId)) {
              review.reportedBy.push(userId);
              review.reportCount += 1;
            }

            if (review.reportCount >= REPORT_HIDE_THRESHOLD) {
              review.isHidden = true;
              review.moderationStatus = 'flagged_hidden';
            }

            await review.save();
            return {
              success: true,
              message: review.isHidden
                ? 'Review reported and hidden pending admin moderation.'
                : 'Review report recorded. Thank you for keeping Sanchari safe.',
              isHidden: review.isHidden,
              reportCount: review.reportCount,
              review,
            };
          }
        }
      } catch (err) {
        console.warn(`[ReviewService] MongoDB reportReview error: ${err.message}`);
      }
    }

    review = this._inMemoryReviews.find((r) => r.id === reviewId || r._id === reviewId);
    if (review) {
      if (!review.reportedBy.includes(userId)) {
        review.reportedBy.push(userId);
        review.reportCount += 1;
      }

      if (review.reportCount >= REPORT_HIDE_THRESHOLD) {
        review.isHidden = true;
        review.moderationStatus = 'flagged_hidden';
      }

      return {
        success: true,
        message: review.isHidden
          ? 'Review reported and hidden pending admin moderation.'
          : 'Review report recorded. Thank you for keeping Sanchari safe.',
        isHidden: review.isHidden,
        reportCount: review.reportCount,
        review,
      };
    }

    return {
      success: true,
      message: 'Report recorded.',
      isHidden: false,
      reportCount: 1,
    };
  }

  /**
   * Admin: Reinstate, dismiss, or permanently delete review
   */
  async adminModerateReview(reviewId, { action = 'approve' }) {
    if (mongoose.connection.readyState === 1) {
      try {
        if (mongoose.isValidObjectId(reviewId)) {
          if (action === 'delete') {
            await Review.findByIdAndDelete(reviewId);
            return { success: true, message: 'Review permanently deleted' };
          }
          const updated = await Review.findByIdAndUpdate(
            reviewId,
            { isHidden: false, moderationStatus: 'approved', reportCount: 0 },
            { new: true }
          );
          return { success: true, message: 'Review reinstated', data: updated };
        }
      } catch (err) {
        console.warn(`[ReviewService] adminModerateReview error: ${err.message}`);
      }
    }

    const idx = this._inMemoryReviews.findIndex((r) => r.id === reviewId || r._id === reviewId);
    if (idx !== -1) {
      if (action === 'delete') {
        this._inMemoryReviews.splice(idx, 1);
        return { success: true, message: 'Review deleted' };
      }
      this._inMemoryReviews[idx].isHidden = false;
      this._inMemoryReviews[idx].moderationStatus = 'approved';
      this._inMemoryReviews[idx].reportCount = 0;
      return { success: true, message: 'Review reinstated', data: this._inMemoryReviews[idx] };
    }

    return { success: true };
  }
}

const reviewService = new ReviewService();

module.exports = reviewService;

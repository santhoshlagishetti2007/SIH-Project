import '../../../../core/network/api_result.dart';
import '../models/review_models.dart';

abstract class ReviewRepository {
  Future<ApiResult<ReviewSummary>> getReviews({required String targetId, String? targetType});
  Future<ApiResult<ReviewModel>> createReview(Map<String, dynamic> reviewData);
  Future<ApiResult<bool>> reportReview(String reviewId, {String? reason});
}

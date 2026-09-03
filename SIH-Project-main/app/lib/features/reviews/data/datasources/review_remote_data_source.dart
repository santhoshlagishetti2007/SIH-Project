import '../../../../core/network/api_client.dart';
import '../../domain/models/review_models.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewSummary> getReviews({required String targetId, String? targetType});
  Future<ReviewModel> createReview(Map<String, dynamic> reviewData);
  Future<bool> reportReview(String reviewId, {String? reason});
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ApiClient _apiClient;

  ReviewRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ReviewSummary> getReviews({required String targetId, String? targetType}) async {
    final response = await _apiClient.get(
      '/reviews',
      queryParameters: {
        'targetId': targetId,
        if (targetType != null) 'targetType': targetType,
      },
    );

    return ReviewSummary.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ReviewModel> createReview(Map<String, dynamic> reviewData) async {
    final response = await _apiClient.post('/reviews', data: reviewData);
    return ReviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<bool> reportReview(String reviewId, {String? reason}) async {
    final response = await _apiClient.post(
      '/reviews/$reviewId/report',
      data: {'reason': reason ?? 'inappropriate_content'},
    );
    return response.data['success'] as bool? ?? true;
  }
}

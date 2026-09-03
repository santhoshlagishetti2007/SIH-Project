import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/review_remote_data_source.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/models/review_models.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewsState {
  final ReviewSummary? summary;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  const ReviewsState({
    this.summary,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ReviewsState copyWith({
    ReviewSummary? summary,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ReviewsState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = ReviewRemoteDataSourceImpl(apiClient);
  return ReviewRepositoryImpl(remoteDataSource);
});

final reviewsControllerProvider = StateNotifierProvider.family<ReviewsNotifier, ReviewsState, String>(
  (ref, targetId) {
    final repo = ref.watch(reviewRepositoryProvider);
    return ReviewsNotifier(repo, targetId);
  },
);

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ReviewRepository _repository;
  final String _targetId;

  ReviewsNotifier(this._repository, this._targetId) : super(const ReviewsState()) {
    loadReviews();
  }

  Future<void> loadReviews({String? targetType}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getReviews(targetId: _targetId, targetType: targetType);

    result.when(
      success: (data) => state = state.copyWith(summary: data, isLoading: false),
      failure: (err) => state = state.copyWith(isLoading: false, errorMessage: err.message),
    );
  }

  Future<bool> submitReview({
    required String targetType,
    required String userName,
    required double rating,
    required String text,
    List<String>? photos,
    String? userId,
  }) async {
    state = state.copyWith(isSubmitting: true);

    final payload = {
      'targetType': targetType,
      'targetId': _targetId,
      'userId': userId ?? 'traveler_user',
      'userName': userName,
      'rating': rating,
      'text': text,
      'photos': photos ?? [],
    };

    final result = await _repository.createReview(payload);

    return result.when(
      success: (newReview) {
        final currentReviews = state.summary?.reviews ?? [];
        final updatedList = [newReview, ...currentReviews];
        final total = updatedList.length;
        final sum = updatedList.fold<double>(0.0, (acc, r) => acc + r.rating);
        final avg = total > 0 ? (sum / total) : 5.0;

        final updatedSummary = ReviewSummary(
          targetId: _targetId,
          targetType: targetType,
          averageRating: double.parse(avg.toStringAsFixed(1)),
          totalReviews: total,
          ratingBreakdown: state.summary?.ratingBreakdown ?? const RatingBreakdown(),
          reviews: updatedList,
        );

        state = state.copyWith(summary: updatedSummary, isSubmitting: false);
        return true;
      },
      failure: (_) {
        state = state.copyWith(isSubmitting: false);
        return false;
      },
    );
  }

  Future<bool> reportReview(String reviewId, {String? reason}) async {
    final result = await _repository.reportReview(reviewId, reason: reason);
    return result.when(
      success: (_) {
        loadReviews();
        return true;
      },
      failure: (_) => false,
    );
  }
}

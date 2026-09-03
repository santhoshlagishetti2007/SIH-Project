import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/review_models.dart';
import '../controllers/reviews_controller.dart';
import 'write_review_modal_sheet.dart';

/// Universal Reusable Review Section for Places, Eateries, Local Groups, and Marketplace Finds
class UniversalReviewSection extends ConsumerWidget {
  final String targetId;
  final String targetType;
  final String targetName;

  const UniversalReviewSection({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  void _confirmReportReview(BuildContext context, WidgetRef ref, String reviewId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag_outlined, color: Colors.red),
            SizedBox(width: 8),
            Text('Report Inappropriate Review?'),
          ],
        ),
        content: const Text(
          'Flag this review for spam, inappropriate language, or misinformation? Reviews with multiple reports will be hidden pending admin moderation.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final notifier = ref.read(reviewsControllerProvider(targetId).notifier);
              final success = await notifier.reportReview(reviewId);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('🚩 Review reported. Thank you for keeping our community authentic and safe.'),
                  ),
                );
              }
            },
            child: const Text('Report & Flag'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewsControllerProvider(targetId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final summary = state.summary;
    final reviews = summary?.reviews ?? [];
    final avgRating = summary?.averageRating ?? 0.0;
    final totalCount = summary?.totalReviews ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.rate_review_outlined, size: 20, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Traveler Reviews & Ratings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => WriteReviewModalSheet.show(
                context,
                targetId: targetId,
                targetType: targetType,
                targetName: targetName,
              ),
              icon: const Icon(Icons.edit, size: 14),
              label: const Text('Write Review', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Rating Summary Hero Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Left: Big Score
              Column(
                children: [
                  Text(
                    avgRating > 0 ? avgRating.toStringAsFixed(1) : '5.0',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final starVal = i + 1;
                      return Icon(
                        starVal <= avgRating ? Icons.star_rounded : (starVal - 0.5 <= avgRating ? Icons.star_half_rounded : Icons.star_border_rounded),
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCount verified reviews',
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Right: Star distribution bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, summary?.ratingBreakdown.star5 ?? 0, totalCount),
                    _buildRatingBar(4, summary?.ratingBreakdown.star4 ?? 0, totalCount),
                    _buildRatingBar(3, summary?.ratingBreakdown.star3 ?? 0, totalCount),
                    _buildRatingBar(2, summary?.ratingBreakdown.star2 ?? 0, totalCount),
                    _buildRatingBar(1, summary?.ratingBreakdown.star1 ?? 0, totalCount),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Reviews List
        if (state.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (reviews.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.reviews_outlined, color: Colors.grey, size: 36),
                  const SizedBox(height: 6),
                  const Text('No reviews yet. Be the first to share your experience!'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => WriteReviewModalSheet.show(
                      context,
                      targetId: targetId,
                      targetType: targetType,
                      targetName: targetName,
                    ),
                    child: const Text('Add First Review'),
                  ),
                ],
              ),
            ),
          )
        else
          ...reviews.map((r) => _buildReviewCard(context, ref, r, isDark)),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final pct = total > 0 ? (count / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars★', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('$count', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, WidgetRef ref, ReviewModel review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Rating, and Report Button
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'T',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 13,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Flag / Report Action
              IconButton(
                icon: const Icon(Icons.flag_outlined, size: 16, color: Colors.grey),
                tooltip: 'Report Review',
                onPressed: () => _confirmReportReview(context, ref, review.id),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Review Text
          Text(
            review.text,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          // Photos (if any)
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      review.photos[idx],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

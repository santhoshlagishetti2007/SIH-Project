import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/eatery_model.dart';
import '../../domain/models/trip_model.dart';
import 'eatery_detail_modal_sheet.dart';

/// "Eat Nearby" Section rendered inside / below each itinerary stop card
class EatNearbySection extends StatelessWidget {
  final List<NearbyEatery> eateries;
  final ItineraryStop stop;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final bool isDark;

  const EatNearbySection({
    super.key,
    required this.eateries,
    required this.stop,
    this.isLoading = false,
    this.onRefresh,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            ),
            SizedBox(height: 8),
            Text('Finding authentic local eateries nearby...', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      );
    }

    if (eateries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              const Icon(Icons.restaurant_rounded, size: 14, color: AppColors.accentDark),
              const SizedBox(width: 6),
              const Text(
                'EAT NEARBY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.9,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• Authentic & Local (Top 3)',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Horizontal 3-card carousel
          SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: eateries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final eatery = eateries[index];
                return _buildEateryCard(context, eatery);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEateryCard(BuildContext context, NearbyEatery eatery) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => EateryDetailModalSheet(
            eatery: eatery,
            currentStop: stop,
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 195,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : Colors.grey.shade300,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eatery Photo + Cuisine Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    eatery.photoUrl.isNotEmpty
                        ? eatery.photoUrl
                        : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&auto=format&fit=crop&q=80',
                    height: 95,
                    width: 195,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 95,
                      width: 195,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.restaurant, size: 28, color: Colors.grey),
                    ),
                  ),
                ),

                // Distance Tag Pill
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '${eatery.distanceMeters}m',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Body: Name, Cuisine, Rating & Price
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eatery.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    eatery.cuisineType,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Rating
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            eatery.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price Level
                      Text(
                        '${eatery.priceLevel} • ~₹${eatery.estimatedCost.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

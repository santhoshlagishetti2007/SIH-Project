import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/destination_customs_controller.dart';
import 'destination_info_modal_sheet.dart';

/// Dismissible "Know Before You Go" banner card displayed at the start of itinerary viewing
class KnowBeforeYouGoCard extends ConsumerWidget {
  final String destination;

  const KnowBeforeYouGoCard({
    super.key,
    this.destination = 'Jaipur',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(destinationCustomsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isDismissed || state.customs == null) {
      return const SizedBox.shrink();
    }

    final customs = state.customs!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, Badge, and Dismiss Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFD97706),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KNOW BEFORE YOU GO: ${customs.destination.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const Text(
                        'Local customs, dress codes & temple etiquette',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Dismiss Action
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey,
                  tooltip: 'Dismiss Card',
                  onPressed: () => ref.read(destinationCustomsControllerProvider.notifier).dismissCard(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Key Quick-Read Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildSummaryChip(
                  Icons.checkroom_rounded,
                  'Dress: Modest lightweight',
                  Colors.purple,
                  isDark,
                ),
                _buildSummaryChip(
                  Icons.temple_hindu_rounded,
                  'Temples: Remove shoes',
                  Colors.orange,
                  isDark,
                ),
                _buildSummaryChip(
                  Icons.payments_outlined,
                  'Tipping: ~7-10%',
                  Colors.teal,
                  isDark,
                ),
                if (customs.commonScams.isNotEmpty)
                  _buildSummaryChip(
                    Icons.warning_amber_rounded,
                    'Scam Alert: Gemstone export touts',
                    Colors.redAccent,
                    isDark,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Action: Explore Full Guide
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💡 Always keep shoes at temple stands',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                InkWell(
                  onTap: () => DestinationInfoModalSheet.show(context, customs),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Full Guide',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

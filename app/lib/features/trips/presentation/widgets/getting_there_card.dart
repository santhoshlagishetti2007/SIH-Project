import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';
import 'book_cab_modal_sheet.dart';

/// Interactive "Getting There" Card rendered between consecutive stops with multi-mode selection,
/// side-by-side Public Transport vs. Cab comparison, and Uber/Ola deep-link booking.
class GettingThereCard extends StatelessWidget {
  final TransitLeg transitLeg;
  final ItineraryStop? fromStop;
  final ItineraryStop? toStop;
  final Function(String selectedMode) onModeSelected;
  final bool isDark;

  const GettingThereCard({
    super.key,
    required this.transitLeg,
    this.fromStop,
    this.toStop,
    required this.onModeSelected,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption = transitLeg.modes.firstWhere(
      (m) => m.mode == transitLeg.selectedMode,
      orElse: () => transitLeg.modes.isNotEmpty
          ? transitLeg.modes.first
          : TransitModeOption(
              mode: transitLeg.selectedMode,
              label: transitLeg.selectedMode,
              icon: '',
              cost: transitLeg.estimatedCost,
              durationMinutes: transitLeg.durationMinutes,
            ),
    );

    // 1. Identify Public Transport Option (Bus / Metro / Auto / Walk)
    final publicOption = transitLeg.modes.firstWhere(
      (m) => m.mode == 'bus' || m.mode == 'metro' || m.mode == 'auto',
      orElse: () => transitLeg.modes.isNotEmpty
          ? transitLeg.modes.first
          : const TransitModeOption(mode: 'bus', label: 'Bus', icon: '', cost: 15, durationMinutes: 22),
    );

    // 2. Identify Cab Option
    final cabOption = transitLeg.modes.firstWhere(
      (m) => m.mode == 'cab',
      orElse: () => TransitModeOption(
        mode: 'cab',
        label: 'Cab',
        icon: 'local_taxi',
        cost: (transitLeg.distanceKm * 18.0 + 60.0).clamp(60.0, 9999.0),
        durationMinutes: (transitLeg.distanceKm / 25 * 60).round() + 3,
      ),
    );

    final timeSaved = (publicOption.durationMinutes - cabOption.durationMinutes).clamp(0, 120);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        children: [
          // Top connector line
          _buildDashedConnector(),

          // Main "Getting there" transit card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.9)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                width: 0.9,
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
                // Header row: Distance & Selected Mode Duration & Cost
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getModeIcon(transitLeg.selectedMode),
                        size: 16,
                        color: AppColors.accentDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'GETTING THERE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.9,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• ${transitLeg.distanceKm.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '~${selectedOption.durationMinutes} mins by ${selectedOption.label.isNotEmpty ? selectedOption.label : transitLeg.selectedMode.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cost Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedOption.cost == 0
                            ? Colors.green.withOpacity(0.15)
                            : AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        selectedOption.cost == 0
                            ? 'FREE'
                            : '₹${selectedOption.cost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selectedOption.cost == 0
                              ? Colors.green.shade700
                              : AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Side-by-Side Comparison Chip: "Public transport ~₹X · 25 min" vs "Cab ~₹Y · 12 min"
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : Colors.grey.shade200,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Public Transport Side
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _getModeIcon(publicOption.mode),
                              size: 14,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Public Transport',
                                    style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '~₹${publicOption.cost.toStringAsFixed(0)} · ${publicOption.durationMinutes}m',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider VS Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),

                      // Cab Side
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Cab / Ride',
                                        style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w600),
                                      ),
                                      if (timeSaved > 0)
                                        const Text(' ⚡', style: TextStyle(fontSize: 9)),
                                    ],
                                  ),
                                  Text(
                                    '~₹${cabOption.cost.toStringAsFixed(0)} · ${cabOption.durationMinutes}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: timeSaved > 0 ? AppColors.accentDark : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.local_taxi_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Multi-Modal Mode Selection Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: transitLeg.modes.map((option) {
                      final isSelected = option.mode == transitLeg.selectedMode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => onModeSelected(option.mode),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.borderDark
                                        : Colors.grey.shade300),
                                width: isSelected ? 1.4 : 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getModeIcon(option.mode),
                                  size: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  option.label.isNotEmpty ? option.label : _formatModeLabel(option.mode),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  option.cost == 0
                                      ? '(Free)'
                                      : '(₹${option.cost.toStringAsFixed(0)})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppColors.accentLight
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // "Book a cab instead" Action CTA Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final effectiveFrom = fromStop ??
                          ItineraryStop(
                            id: transitLeg.fromStopId,
                            name: transitLeg.fromStopName.isNotEmpty
                                ? transitLeg.fromStopName
                                : 'Current Stop',
                            location: const LocationData(lat: 26.9855, lng: 75.8513),
                          );

                      final effectiveTo = toStop ??
                          ItineraryStop(
                            id: transitLeg.toStopId,
                            name: transitLeg.toStopName.isNotEmpty
                                ? transitLeg.toStopName
                                : 'Next Stop',
                            location: const LocationData(lat: 26.9845, lng: 75.8456),
                          );

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BookCabModalSheet(
                          fromStop: effectiveFrom,
                          toStop: effectiveTo,
                          transitLeg: transitLeg,
                          onSwitchToCabMode: () => onModeSelected('cab'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_taxi_rounded, size: 15, color: Colors.amber),
                    label: Text(
                      'Book a cab instead (Uber / Ola) · ₹${cabOption.cost.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: isDark ? Colors.amber.withOpacity(0.5) : Colors.amber.shade700,
                        width: 1.0,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom connector line
          _buildDashedConnector(),
        ],
      ),
    );
  }

  Widget _buildDashedConnector() {
    return Container(
      width: 2,
      height: 10,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  IconData _getModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'walk':
        return Icons.directions_walk_rounded;
      case 'auto':
        return Icons.electric_rickshaw_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'metro':
        return Icons.subway_rounded;
      case 'cab':
      case 'taxi':
        return Icons.local_taxi_rounded;
      default:
        return Icons.directions_transit_rounded;
    }
  }

  String _formatModeLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'walk':
        return 'Walk';
      case 'auto':
        return 'Auto';
      case 'bus':
        return 'Bus';
      case 'metro':
        return 'Metro';
      case 'cab':
        return 'Cab';
      default:
        return mode.toUpperCase();
    }
  }
}

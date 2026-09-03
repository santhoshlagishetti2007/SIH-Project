import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/cab_deep_link_service.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';

/// Modal Bottom Sheet to book a cab via Uber or Ola with prefilled pickup/drop-off coordinates
class BookCabModalSheet extends StatelessWidget {
  final ItineraryStop fromStop;
  final ItineraryStop toStop;
  final TransitLeg transitLeg;
  final VoidCallback? onSwitchToCabMode;

  const BookCabModalSheet({
    super.key,
    required this.fromStop,
    required this.toStop,
    required this.transitLeg,
    this.onSwitchToCabMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cabOption = transitLeg.modes.firstWhere(
      (m) => m.mode == 'cab',
      orElse: () => TransitModeOption(
        mode: 'cab',
        label: 'Cab / Taxi',
        icon: 'local_taxi',
        cost: (transitLeg.distanceKm * 18.0 + 60.0).clamp(60.0, 9999.0),
        durationMinutes: (transitLeg.distanceKm / 25 * 60).round() + 3,
      ),
    );

    final publicOption = transitLeg.modes.firstWhere(
      (m) => m.mode == 'bus' || m.mode == 'metro' || m.mode == 'auto',
      orElse: () => transitLeg.modes.isNotEmpty
          ? transitLeg.modes.first
          : const TransitModeOption(mode: 'transit', label: 'Transit', icon: '', cost: 20, durationMinutes: 25),
    );

    final timeSaved = (publicOption.durationMinutes - cabOption.durationMinutes).clamp(0, 120);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sheet Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: AppColors.primaryLight, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book a Cab Instead',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Direct deep-link with prefilled pickup & drop-off',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Route Preview Card (Pickup -> Dropoff)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                // Pickup Stop
                Row(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 16, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PICKUP LOCATION',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Text(
                            fromStop.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Row(
                    children: [
                      SizedBox(width: 2),
                      CustomPaint(
                        size: Size(2, 16),
                      ),
                    ],
                  ),
                ),

                // Drop-off Stop
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DROP-OFF DESTINATION',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Text(
                            toStop.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Quick Route Stats & Time Saver Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, size: 15, color: AppColors.accentDark),
                    const SizedBox(width: 6),
                    Text(
                      '${transitLeg.distanceKm.toStringAsFixed(1)} km • ~${cabOption.durationMinutes} min',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (timeSaved > 0)
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 14, color: Colors.amber),
                      Text(
                        ' $timeSaved min faster than transit',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Booking Provider Options (Uber & Ola)
          Expanded(
            child: ListView(
              children: [
                // 1. Uber Action Card
                _buildRideProviderCard(
                  context: context,
                  title: 'Uber',
                  subtitle: 'Request Uber Go / Premier / Auto',
                  fareText: 'Est. ₹${cabOption.cost.toStringAsFixed(0)}',
                  iconWidget: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Uber',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  buttonColor: Colors.black87,
                  buttonTextColor: Colors.white,
                  buttonLabel: 'Book on Uber',
                  onTap: () async {
                    Navigator.pop(context);
                    onSwitchToCabMode?.call();
                    final ok = await CabDeepLinkService.launchUberRide(
                      pickupLat: fromStop.location.lat,
                      pickupLng: fromStop.location.lng,
                      pickupName: fromStop.name,
                      pickupAddress: fromStop.location.address,
                      dropoffLat: toStop.location.lat,
                      dropoffLng: toStop.location.lng,
                      dropoffName: toStop.name,
                      dropoffAddress: toStop.location.address,
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open Uber. Opening browser...')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                // 2. Ola Action Card
                _buildRideProviderCard(
                  context: context,
                  title: 'Ola Cabs',
                  subtitle: 'Request Ola Mini / Prime / Auto',
                  fareText: 'Est. ₹${cabOption.cost.toStringAsFixed(0)}',
                  iconWidget: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1ABC9C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'OLA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  buttonColor: const Color(0xFF1ABC9C),
                  buttonTextColor: Colors.white,
                  buttonLabel: 'Book on Ola',
                  onTap: () async {
                    Navigator.pop(context);
                    onSwitchToCabMode?.call();
                    final ok = await CabDeepLinkService.launchOlaRide(
                      pickupLat: fromStop.location.lat,
                      pickupLng: fromStop.location.lng,
                      pickupName: fromStop.name,
                      dropoffLat: toStop.location.lat,
                      dropoffLng: toStop.location.lng,
                      dropoffName: toStop.name,
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open Ola. Opening browser...')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 12),

                // 3. Google Maps Driving Directions Option
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    CabDeepLinkService.launchGoogleMaps(
                      pickupLat: fromStop.location.lat,
                      pickupLng: fromStop.location.lng,
                      pickupName: fromStop.name,
                      dropoffLat: toStop.location.lat,
                      dropoffLng: toStop.location.lng,
                      dropoffName: toStop.name,
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('View Live Route in Google Maps'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideProviderCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String fareText,
    required Widget iconWidget,
    required Color buttonColor,
    required Color buttonTextColor,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Spacer(),
                      Text(
                        fareText,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
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

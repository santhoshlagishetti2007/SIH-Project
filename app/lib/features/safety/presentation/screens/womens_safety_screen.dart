import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../location/presentation/controllers/safety_controller.dart';
import '../../domain/models/womens_safety_models.dart';
import '../controllers/womens_safety_controller.dart';
import 'fake_call_screen.dart';

/// Comprehensive Women's Safety Hub Screen
class WomensSafetyScreen extends ConsumerStatefulWidget {
  const WomensSafetyScreen({super.key});

  @override
  ConsumerState<WomensSafetyScreen> createState() => _WomensSafetyScreenState();
}

class _WomensSafetyScreenState extends ConsumerState<WomensSafetyScreen> {
  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(womensSafetyControllerProvider);
    final notifier = ref.read(womensSafetyControllerProvider.notifier);
    final safetyState = ref.watch(safetyControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final guide = state.guide;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Color(0xFFE53E3E), size: 24),
            SizedBox(width: 8),
            Text(
              "Women's Safety Hub",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // City Selector Pill
          _buildCitySelector(context, state, notifier, isDark),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.refresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Quick-Access Action Grid
              _buildQuickAccessGrid(context, safetyState),

              const SizedBox(height: 24),

              // 2. Nearest Emergency Stations (Police & Hospital)
              const Row(
                children: [
                  Icon(Icons.local_police_rounded, size: 20, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Nearest Verified Emergency Services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.emergencyStations.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...state.emergencyStations.map((st) => _buildStationCard(context, st, isDark)),

              const SizedBox(height: 24),

              // 3. Destination Safety Guidelines Card
              if (guide != null) ...[
                _buildDestinationGuideCard(context, guide, isDark),
                const SizedBox(height: 24),
              ],

              // 4. Women-Verified Stays & Female Guides
              const Row(
                children: [
                  Icon(Icons.verified_user_rounded, size: 20, color: Color(0xFFDD6B20)),
                  SizedBox(width: 8),
                  Text(
                    'Women-Verified Stays & Female Guides',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.verifiedListings.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...state.verifiedListings.map((l) => _buildVerifiedListingCard(context, l, isDark)),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelector(
    BuildContext context,
    WomensSafetyState state,
    WomensSafetyNotifier notifier,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: state.selectedCity,
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          isDense: true,
          items: state.supportedCities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    city,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList>,
          onChanged: (city) {
            if (city != null) notifier.setCity(city);
          },
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context, SafetyState safetyState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instant Emergency & Exit Tools',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 1. Women Helpline 1091
            Expanded(
              child: _buildActionTile(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFFE53E3E),
                title: '1091 Helpline',
                subtitle: 'National Women Safety',
                onTap: () => _makeCall('1091'),
              ),
            ),
            const SizedBox(width: 10),
            // 2. Fake Call Simulator
            Expanded(
              child: _buildActionTile(
                icon: Icons.ring_volume_rounded,
                iconColor: const Color(0xFF805AD5),
                title: 'Fake Call (5s)',
                subtitle: 'Discreet Exit Strategy',
                onTap: () => FakeCallScreen.launch(context, delaySeconds: 5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. One-Tap Live Location Share
            Expanded(
              child: _buildActionTile(
                icon: Icons.share_location_rounded,
                iconColor: safetyState.isLocationSharingActive ? Colors.green : AppColors.primaryLight,
                title: safetyState.isLocationSharingActive ? 'Sharing ON' : 'Share Location',
                subtitle: 'Live Tracking Link',
                onTap: () async {
                  if (safetyState.isLocationSharingActive) {
                    await ref.read(safetyControllerProvider.notifier).stopSharing();
                  } else {
                    await ref.read(safetyControllerProvider.notifier).startTripShare();
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            // 4. Dial 112
            Expanded(
              child: _buildActionTile(
                icon: Icons.emergency_rounded,
                iconColor: const Color(0xFFDD6B20),
                title: 'Dial 112',
                subtitle: 'Police & Medical',
                onTap: () => _makeCall('112'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.25), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(BuildContext context, EmergencyStation st, bool isDark) {
    final isPolice = st.type == 'police';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isPolice ? AppColors.primary.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPolice ? Icons.local_police_rounded : Icons.local_hospital_rounded,
                color: isPolice ? AppColors.primary : Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    st.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${st.distanceText}',
                    style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    st.address,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Call Button
            IconButton(
              tooltip: 'Call Emergency Station',
              icon: const Icon(Icons.phone_rounded, color: Color(0xFF38A169)),
              onPressed: () => _makeCall(st.phone),
            ),
            // Directions Button
            IconButton(
              tooltip: 'Get Directions',
              icon: const Icon(Icons.directions_rounded, color: AppColors.primaryLight),
              onPressed: () => _openDirections(st.lat, st.lng),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationGuideCard(BuildContext context, WomensSafetyGuide guide, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${guide.city} Safety & Transit Guide',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),

            // Safe Areas
            const Text(
              '🟢 Recommended Safe Areas:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF38A169)),
            ),
            const SizedBox(height: 6),
            ...guide.safeAreas.map((area) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $area', style: const TextStyle(fontSize: 12, height: 1.4)),
                )),

            const SizedBox(height: 14),

            // Caution Areas
            const Text(
              '🟡 Areas to Exercise Caution (After Dark):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFDD6B20)),
            ),
            const SizedBox(height: 6),
            ...guide.cautionAreas.map((area) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $area', style: const TextStyle(fontSize: 12, height: 1.4)),
                )),

            const SizedBox(height: 14),

            // Transport Advice Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions_transit_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Night Transit & Cabs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.transportAdvice.nightTransit,
                    style: const TextStyle(fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedListingCard(BuildContext context, WomenVerifiedListing l, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                l.photo,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'WOMEN-VERIFIED',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${l.rating}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: l.safetyBadges.map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purple.withOpacity(0.2)),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  l.description,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

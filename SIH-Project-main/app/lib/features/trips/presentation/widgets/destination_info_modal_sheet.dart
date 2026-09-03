import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/destination_customs_models.dart';

/// Modal bottom sheet presenting complete "Know Before You Go" cultural etiquette and scam prevention guide
class DestinationInfoModalSheet extends StatelessWidget {
  final DestinationCustoms customs;

  const DestinationInfoModalSheet({super.key, required this.customs});

  static void show(BuildContext context, DestinationCustoms customs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DestinationInfoModalSheet(customs: customs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Know Before You Go: ${customs.destination}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Cultural etiquette, dress codes & scam alerts',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
              children: [
                // 1. Top Do's & Don'ts Grid
                _buildSectionHeader('DO\'S & DON\'TS', Icons.checklist_rounded, AppColors.secondary),
                const SizedBox(height: 10),
                _buildDosAndDonts(isDark),

                const SizedBox(height: 24),

                // 2. Dress Code & Modesty
                _buildSectionHeader('DRESS CODE & MODESTY', Icons.checkroom_rounded, Colors.purple),
                const SizedBox(height: 10),
                _buildDressCodeCard(isDark),

                const SizedBox(height: 24),

                // 3. Temple & Religious Site Etiquette
                _buildSectionHeader('TEMPLE & SACRED SITES ETIQUETTE', Icons.account_balance_rounded, Colors.orange),
                const SizedBox(height: 10),
                _buildTempleEtiquetteCard(isDark),

                const SizedBox(height: 24),

                // 4. Common Scams & Tourist Traps to Avoid
                _buildSectionHeader('COMMON SCAMS TO AVOID', Icons.warning_amber_rounded, Colors.redAccent),
                const SizedBox(height: 10),
                _buildScamsList(isDark),

                const SizedBox(height: 24),

                // 5. Tipping Norms
                _buildSectionHeader('TIPPING NORMS', Icons.payments_outlined, Colors.teal),
                const SizedBox(height: 10),
                _buildTippingCard(isDark),

                if (customs.localCustoms.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader('LOCAL TRADITIONS & CUSTOMS', Icons.diversity_1_rounded, AppColors.primaryLight),
                  const SizedBox(height: 10),
                  ...customs.localCustoms.map((c) => _buildBulletPoint(c, Icons.star_rounded, AppColors.primaryLight)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDosAndDonts(bool isDark) {
    return Column(
      children: [
        // Do's Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF38A169).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF38A169).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF38A169), size: 16),
                  SizedBox(width: 6),
                  Text('ALWAYS DO', style: TextStyle(color: Color(0xFF38A169), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ...customs.dos.map((d) => _buildBulletPoint(d, Icons.check, const Color(0xFF38A169))),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Don'ts Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Color(0xFFE53E3E), size: 16),
                  SizedBox(width: 6),
                  Text('AVOID DOING', style: TextStyle(color: Color(0xFFE53E3E), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              ...customs.donts.map((d) => _buildBulletPoint(d, Icons.close, const Color(0xFFE53E3E))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDressCodeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('General Exploring', customs.dressCode.general, Icons.wb_sunny_outlined),
          const Divider(height: 16),
          _buildInfoRow('Temples & Shrines', customs.dressCode.religiousSites, Icons.temple_hindu_rounded),
          const Divider(height: 16),
          _buildInfoRow('Nightlife & Cafes', customs.dressCode.nightlife, Icons.nightlife_rounded),
        ],
      ),
    );
  }

  Widget _buildTempleEtiquetteCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
      ),
      child: Column(
        children: customs.templeEtiquette
            .map((rule) => _buildBulletPoint(rule, Icons.fiber_manual_record, Colors.orange, size: 8))
            .toList(),
      ),
    );
  }

  Widget _buildScamsList(bool isDark) {
    return Column(
      children: customs.commonScams.map((scam) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scam.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '⚠️ ${scam.warning}',
                style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.redAccent),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tip: ${scam.preventionTip}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTippingCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow('Restaurants', customs.tippingNorms.restaurants, Icons.restaurant_rounded),
          const Divider(height: 16),
          _buildInfoRow('Cabs & Autos', customs.tippingNorms.autosCabs, Icons.local_taxi_rounded),
          const Divider(height: 16),
          _buildInfoRow('Guides & Drivers', customs.tippingNorms.guidesDrivers, Icons.person_pin_circle_rounded),
          const Divider(height: 16),
          _buildInfoRow('Hotel Staff', customs.tippingNorms.hotelStaff, Icons.hotel_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 12, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, IconData icon, Color color, {double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: size, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

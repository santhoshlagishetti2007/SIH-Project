import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/models/user_model.dart';
import '../../../health/presentation/screens/hello_sanchari_screen.dart';
import '../../../settings/presentation/widgets/language_picker_dialog.dart';
import '../../../translate/presentation/screens/live_translate_screen.dart';
import '../../../trips/presentation/screens/trip_itinerary_screen.dart';
import '../controllers/auth_controller.dart';
import 'profile_setup_screen.dart';

class UserDashboardScreen extends ConsumerWidget {
  final UserModel user;

  const UserDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.explore, color: AppColors.accent, size: 26),
            const SizedBox(width: 8),
            Text(
              l10n.appName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        actions: [
          // Language Picker
          IconButton(
            tooltip: l10n.selectLanguage,
            icon: const Icon(Icons.translate_rounded),
            onPressed: () => LanguagePickerDialog.show(context),
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.tune_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
              );
            },
          ),
          IconButton(
            tooltip: l10n.signOut,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Greeting Profile Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.accent.withOpacity(0.3),
                        child: Text(
                          user.displayName.isNotEmpty
                              ? user.displayName.substring(0, 1).toUpperCase()
                              : 'T',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user.displayName} 👋',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email.isNotEmpty ? user.email : (user.phone ?? 'Authenticated Explorer'),
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Traveler Persona & Details Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Traveler Persona Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent.withOpacity(0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(user.travelerType.icon, color: AppColors.accentLight, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              user.travelerType.title,
                              style: const TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Home City Badge
                      if (user.homeCity.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                user.homeCity,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                      // Clickable Language Picker Badge
                      InkWell(
                        onTap: () => LanguagePickerDialog.show(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.translate, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                user.preferredLanguage.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Emergency Contacts Safety Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: user.emergencyContacts.isNotEmpty
                    ? AppColors.secondary.withOpacity(0.08)
                    : AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: user.emergencyContacts.isNotEmpty
                    ? AppColors.secondary.withOpacity(0.3)
                    : AppColors.warning.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: user.emergencyContacts.isNotEmpty
                          ? AppColors.secondary.withOpacity(0.15)
                          : AppColors.warning.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      user.emergencyContacts.isNotEmpty
                          ? Icons.shield_rounded
                          : Icons.warning_amber_rounded,
                      color: user.emergencyContacts.isNotEmpty
                          ? AppColors.secondary
                          : AppColors.warning,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.emergencyContacts.isNotEmpty
                              ? '${l10n.safetyNetwork} (${user.emergencyContacts.length})'
                              : 'Safety Network Incomplete',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.emergencyContacts.isNotEmpty
                              ? 'Emergency SOS triggers and location pings are linked.'
                              : 'Add emergency contacts for automated safety alerts.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                      );
                    },
                    child: Text(l10n.settings),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Modules & Feature Hub
            Text(
              l10n.travelerDashboard,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            // Action Hub Cards
            _buildFeatureCard(
              icon: Icons.record_voice_over_rounded,
              iconColor: AppColors.accent,
              title: '${l10n.liveTranslateTitle} (${l10n.walkieTalkieMode})',
              subtitle: 'Two-panel voice translation with Google STT/TTS & offline phrasebook',
              badge: 'LIVE TOOL',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveTranslateScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.map_rounded,
              iconColor: AppColors.primaryLight,
              title: '${l10n.itinerary} & ${l10n.transport}',
              subtitle: 'Drag reorder, Places swap, multi-modal transport & eat nearby',
              badge: 'INTERACTIVE',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripItineraryScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.translate_rounded,
              iconColor: Colors.purple,
              title: l10n.selectLanguage,
              subtitle: l10n.appLanguageSubtitle,
              badge: user.preferredLanguage.toUpperCase(),
              onTap: () => LanguagePickerDialog.show(context),
            ),

            const SizedBox(height: 12),

            _buildFeatureCard(
              icon: Icons.health_and_safety_outlined,
              iconColor: AppColors.secondary,
              title: 'Backend Health & Diagnostics',
              subtitle: 'Ping Node.js + MongoDB API and inspect token auth state',
              badge: 'DIAGNOSTICS',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HelloSanchariScreen()),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOut),
        content: const Text('Are you sure you want to sign out of Sanchari?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.signOut, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

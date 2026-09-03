import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../features/auth/presentation/screens/user_dashboard_screen.dart';
import '../../../features/health/presentation/screens/hello_sanchari_screen.dart';
import '../../../features/translate/presentation/screens/live_translate_screen.dart';
import '../../../features/trips/presentation/screens/trip_itinerary_screen.dart';
import '../../auth/presentation/controllers/auth_controller.dart';

/// Main Root Navigation Scaffold with persistent BottomNavigationBar
class MainNavScaffold extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends ConsumerState<MainNavScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context);

    final pages = <Widget>[
      const TripItineraryScreen(),
      const LiveTranslateScreen(),
      if (user != null)
        UserDashboardScreen(user: user)
      else
        const HelloSanchariScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map_rounded, color: AppColors.primary),
            label: l10n.itinerary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.record_voice_over_outlined),
            selectedIcon: const Icon(Icons.record_voice_over_rounded, color: AppColors.accent),
            label: l10n.translate,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.secondary),
            label: l10n.profileHub,
          ),
        ],
      ),
    );
  }
}

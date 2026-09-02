import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/firebase_service.dart';
import '../controllers/health_controller.dart';
import '../widgets/health_status_card.dart';

class HelloSanchariScreen extends ConsumerStatefulWidget {
  const HelloSanchariScreen({super.key});

  @override
  ConsumerState<HelloSanchariScreen> createState() => _HelloSanchariScreenState();
}

class _HelloSanchariScreenState extends ConsumerState<HelloSanchariScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically trigger an initial health check on boot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthControllerProvider.notifier).checkHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthControllerProvider);
    final firebaseStatus = ref.watch(firebaseStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore, color: AppColors.accent, size: 28),
            SizedBox(width: 8),
            Text(
              AppStrings.appName,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(healthControllerProvider.notifier).checkHealth();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.accent),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.accent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'AI POWERED',
                              style: TextStyle(
                                color: AppColors.accentLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'v1.0.0-skeleton',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hello Sanchari',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your next-generation intelligent travel companion. Monorepo skeleton initialized successfully.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section 1: Monorepo System Health
            const Text(
              'Backend Connectivity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Target Base URL: ${ApiConstants.baseUrl}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),

            // Health State Switcher
            switch (healthState) {
              HealthInitial() => _buildPlaceholderCard('Connecting to backend...'),
              HealthLoading() => _buildLoadingCard(),
              HealthSuccess(:final status) => HealthStatusCard(status: status),
              HealthError(:final message, :final statusCode) =>
                _buildErrorCard(message, statusCode),
            },

            const SizedBox(height: 16),

            // Ping Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: healthState is HealthLoading
                    ? null
                    : () {
                        ref.read(healthControllerProvider.notifier).checkHealth();
                      },
                icon: healthState is HealthLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  healthState is HealthLoading
                      ? AppStrings.pingingServer
                      : AppStrings.pingButtonLabel,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Section 2: Architecture & Feature Wiring Skeleton
            const Text(
              'Architecture & Modules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildModuleItem(
              icon: Icons.architecture,
              title: 'Clean Architecture Structure',
              subtitle: 'core/ · domain/ · data/ · presentation/',
              isReady: true,
            ),
            _buildModuleItem(
              icon: Icons.stream,
              title: 'Riverpod State Management',
              subtitle: 'StateNotifier & ProviderScope configured',
              isReady: true,
            ),
            _buildModuleItem(
              icon: Icons.local_fire_department,
              title: 'Firebase Project Wiring',
              subtitle: firebaseStatus == FirebaseStatus.connected
                  ? 'Connected (Auth, Firestore, FCM)'
                  : 'Ready (Offline dev fallback mode)',
              isReady: true,
            ),
            _buildModuleItem(
              icon: Icons.description,
              title: 'API Contract & Docs',
              subtitle: '/docs/API_CONTRACT.md · /docs/ARCHITECTURE.md',
              isReady: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 14),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Pinging /api/v1/health...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, int? statusCode) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Backend Offline ${statusCode != null ? '($statusCode)' : ''}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To test: In /server, run `npm install` and `npm run dev`.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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

  Widget _buildModuleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isReady,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        trailing: Icon(
          isReady ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isReady ? AppColors.success : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

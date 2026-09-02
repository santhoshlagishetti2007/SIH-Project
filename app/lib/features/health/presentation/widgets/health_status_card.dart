import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/health_status.dart';
import 'service_badge.dart';

class HealthStatusCard extends StatelessWidget {
  final HealthStatus status;

  const HealthStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.success, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backend Service Connected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${status.service} v${status.version} (${status.environment})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${status.latencyMs}ms',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ServiceBadge(
                  label: 'Database',
                  value: status.databaseStatus,
                  isOk: status.databaseStatus == 'connected',
                  icon: Icons.storage,
                ),
                ServiceBadge(
                  label: 'Firebase Admin',
                  value: status.firebaseStatus,
                  isOk: status.firebaseStatus == 'initialized',
                  icon: Icons.local_fire_department,
                ),
                ServiceBadge(
                  label: 'Google Gemini',
                  value: status.googleAiConfigured ? 'active' : 'dev-stub',
                  isOk: status.googleAiConfigured,
                  icon: Icons.auto_awesome,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uptime: ${status.uptimeHuman} (${status.uptimeSeconds}s)',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Server Time: ${timeFormat.format(status.serverTime.toLocal())}',
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
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

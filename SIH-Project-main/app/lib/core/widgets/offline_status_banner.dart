import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/network_connectivity_service.dart';
import '../sync/offline_sync_manager.dart';

/// Reusable banner displayed when the app is offline or has pending queued edits
class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final pendingCount = ref.watch(pendingMutationsCountProvider);

    // If online and no pending mutations, do not show banner
    if (isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: !isOnline
            ? (isDark ? const Color(0xFF7C2D12) : const Color(0xFFFEF3C7))
            : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE)),
        border: Border(
          bottom: BorderSide(
            color: !isOnline ? Colors.amber.shade700 : Colors.blue.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            !isOnline ? Icons.cloud_off_rounded : Icons.sync_rounded,
            size: 16,
            color: !isOnline
                ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900)
                : (isDark ? Colors.blue.shade300 : Colors.blue.shade900),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !isOnline
                  ? 'Offline mode — Showing saved data'
                  : 'Reconnected — Syncing $pendingCount pending changes...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: !isOnline
                    ? (isDark ? Colors.amber.shade200 : Colors.amber.shade900)
                    : (isDark ? Colors.blue.shade200 : Colors.blue.shade900),
              ),
            ),
          ),
          if (pendingCount > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (!isOnline ? Colors.amber : Colors.blue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pendingCount queued',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: !isOnline
                      ? (isDark ? Colors.amber.shade200 : Colors.amber.shade900)
                      : (isDark ? Colors.blue.shade200 : Colors.blue.shade900),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (isOnline && pendingCount > 0)
            InkWell(
              onTap: () async {
                final manager = ref.read(offlineSyncManagerProvider);
                await manager.syncPendingMutations();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Synced offline edits to Sanchari server!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Sync Now',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

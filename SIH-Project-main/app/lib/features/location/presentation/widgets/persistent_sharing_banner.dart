import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/safety_controller.dart';

/// Top persistent notification safety banner visible when live location sharing or SOS is active
class PersistentSharingBanner extends ConsumerWidget {
  const PersistentSharingBanner({super.key});

  Future<void> _openTrackingLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tracking link copied to clipboard!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyState = ref.watch(safetyControllerProvider);
    final notifier = ref.read(safetyControllerProvider.notifier);

    if (!safetyState.isLocationSharingActive && !safetyState.isSosActive) {
      return const SizedBox.shrink();
    }

    final isSos = safetyState.isSosActive;
    final trackingUrl = safetyState.publicTrackingUrl ?? 'http://localhost:5000/live-track/${safetyState.activeSessionId}';

    return Container(
      width: double.infinity,
      color: isSos ? const Color(0xFFC53030) : const Color(0xFF2B6CB0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              isSos ? Icons.warning_rounded : Icons.share_location_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSos ? '🚨 EMERGENCY SOS ACTIVE' : '🛡️ LIVE LOCATION SHARING ON',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    'Updating GPS every 10s • Emergency contacts linked',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            // View Map Link
            TextButton(
              onPressed: () => _openTrackingLink(context, trackingUrl),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              child: const Row(
                children: [
                  Icon(Icons.open_in_new, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Stop button
            IconButton(
              tooltip: 'Stop Sharing',
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white, size: 20),
              visualDensity: VisualDensity.compact,
              onPressed: () => notifier.stopSharing(),
            ),
          ],
        ),
      ),
    );
  }
}

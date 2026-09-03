import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../reviews/presentation/widgets/universal_review_section.dart';
import '../../domain/models/local_group_models.dart';
import '../controllers/local_groups_controller.dart';

/// Modal sheet showing verified community group charter, schedule, and join/message actions
class GroupDetailModalSheet extends ConsumerStatefulWidget {
  final LocalGroup group;

  const GroupDetailModalSheet({super.key, required this.group});

  static void show(BuildContext context, LocalGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupDetailModalSheet(group: group),
    );
  }

  @override
  ConsumerState<GroupDetailModalSheet> createState() => _GroupDetailModalSheetState();
}

class _GroupDetailModalSheetState extends ConsumerState<GroupDetailModalSheet> {
  final _messageController = TextEditingController(
    text: 'Hi! I am visiting this week and would love to join your upcoming community walk.',
  );
  bool _showJoinForm = false;
  bool _isDispatched = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitJoinRequest() async {
    final authState = ref.read(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.displayName ?? 'Traveler';
    final userPhone = user?.phone ?? '';

    final notifier = ref.read(localGroupsControllerProvider.notifier);
    final result = await notifier.submitJoinRequest(
      groupId: widget.group.id,
      userName: userName,
      message: _messageController.text.trim(),
      userPhone: userPhone,
    );

    if (mounted) {
      setState(() {
        _isDispatched = true;
      });
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF38A169),
            content: Text('🎉 ${result.message}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final phoneClean = group.leadContact.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final waUrl = 'https://wa.me/$phoneClean?text=Hi%20${group.leadName},%20I%20found%20your%20group%20"${Uri.encodeComponent(group.name)}"%20on%20Sanchari!';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cover Photo with Verification Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    group.coverPhoto,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.groups_rounded, size: 48, color: Colors.grey)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A365D).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          '🛡️ VERIFIED COMMUNITY',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${group.membersCount} Members',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group Name & City
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.city,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: group.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 0.6),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              group.description,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),

            const SizedBox(height: 16),

            // Schedule & Meeting Point Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Schedule: ${group.schedule}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.place_rounded, size: 16, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Meeting: ${group.meetingPoint}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, size: 16, color: Color(0xFF38A169)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Group Lead: ${group.leadName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Verification Check Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A365D).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A365D).withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF38A169), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Charter Verified: ${group.verificationDetails.reviewerNotes}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Join Request Form or Initial Buttons
            if (_showJoinForm) ...[
              if (_isDispatched) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Join request sent! The organizer will reach out to you via SMS / WhatsApp.',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  'Message to Group Organizer:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Introduce yourself and when you plan to join...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitJoinRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38A169),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('SEND JOIN REQUEST & MESSAGE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ] else ...[
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _showJoinForm = true),
                      icon: const Icon(Icons.group_add_rounded, size: 18),
                      label: const Text('Request to Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // WhatsApp
                  IconButton.filled(
                    style: IconButton.filled(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'WhatsApp Organizer',
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    onPressed: () => _launchUrl(waUrl),
                  ),
                  const SizedBox(width: 8),
                  // Call
                  IconButton.filled(
                    style: IconButton.filled(
                      backgroundColor: const Color(0xFF3182CE),
                      foregroundColor: Colors.white,
                    ),
                    tooltip: 'Call Organizer',
                    icon: const Icon(Icons.phone_rounded, size: 20),
                    onPressed: () => _launchUrl('tel:$phoneClean'),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Universal Reviews Section
            UniversalReviewSection(
              targetId: group.id,
              targetType: 'group',
              targetName: group.name,
            ),
          ],
        ),
      ),
    );
  }
}

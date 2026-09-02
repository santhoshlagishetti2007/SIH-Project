import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Reusable status badge widget for services
class ServiceBadge extends StatelessWidget {
  final String label;
  final String value;
  final bool isOk;
  final IconData icon;

  const ServiceBadge({
    super.key,
    required this.label,
    required this.value,
    required this.isOk,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOk ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

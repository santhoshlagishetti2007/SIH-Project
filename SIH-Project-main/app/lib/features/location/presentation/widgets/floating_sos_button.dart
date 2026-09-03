import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/safety_controller.dart';

/// Floating SOS Button visible across all screens with confirmation countdown modal
class FloatingSosButton extends ConsumerStatefulWidget {
  const FloatingSosButton({super.key});

  @override
  ConsumerState<FloatingSosButton> createState() => _FloatingSosButtonState();
}

class _FloatingSosButtonState extends ConsumerState<FloatingSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safetyState = ref.watch(safetyControllerProvider);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: safetyState.isSosActive ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Material(
        elevation: 8,
        shape: const CircleBorder(),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSosConfirmationModal(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: safetyState.isSosActive
                    ? [const Color(0xFFC53030), const Color(0xFFE53E3E)]
                    : [const Color(0xFFE53E3E), const Color(0xFFDD6B20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53E3E).withOpacity(safetyState.isSosActive ? 0.6 : 0.4),
                  blurRadius: safetyState.isSosActive ? 18 : 10,
                  spreadRadius: safetyState.isSosActive ? 4 : 2,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2.2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  Text(
                    safetyState.isSosActive ? 'ACTIVE' : 'SOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSosConfirmationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SosConfirmationSheet(),
    );
  }
}

/// 3-Second Countdown / Confirmation Sheet before triggering emergency SOS
class SosConfirmationSheet extends ConsumerStatefulWidget {
  const SosConfirmationSheet({super.key});

  @override
  ConsumerState<SosConfirmationSheet> createState() => _SosConfirmationSheetState();
}

class _SosConfirmationSheetState extends ConsumerState<SosConfirmationSheet> {
  int _countdown = 3;
  Timer? _timer;
  bool _autoDial112 = true;
  bool _isDispatched = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _triggerSosNow();
      }
    });
  }

  void _cancelSos() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  Future<void> _triggerSosNow() async {
    _timer?.cancel();
    setState(() {
      _isDispatched = true;
    });

    final notifier = ref.read(safetyControllerProvider.notifier);
    final result = await notifier.triggerSos(autoDialHelpline: _autoDial112, context: context);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('🚨 SOS Alert Dispatched! ${result.contactsNotifiedCount} emergency contacts notified with live GPS map.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final contacts = authState is Authenticated ? authState.user.emergencyContacts : [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 18),

          // Countdown Dial Header
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE53E3E).withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE53E3E), width: 3),
            ),
            child: Center(
              child: _isDispatched
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(color: Color(0xFFE53E3E), strokeWidth: 3),
                    )
                  : Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE53E3E),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'EMERGENCY SOS CONFIRMATION',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFFE53E3E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isDispatched
                ? 'Broadcasting live satellite GPS link to your emergency network...'
                : 'Sending emergency alert in $_countdown seconds. Tap Cancel if pressed accidentally.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),

          const SizedBox(height: 18),

          // Notified Contacts List Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.share_location_rounded, size: 16, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Emergency Contacts Receiving Live Map Link:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (contacts.isEmpty)
                  const Text(
                    '• National Emergency Response Center (112)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  )
                else
                  ...contacts.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• ${c.name} (${c.phone}) — ${c.relation}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 112 Auto-Dial Checkbox
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: _autoDial112,
            activeColor: const Color(0xFFE53E3E),
            title: const Text(
              'Also initiate emergency call to 112 (National Helpline)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            onChanged: (val) => setState(() => _autoDial112 = val ?? true),
          ),

          const SizedBox(height: 16),

          // Actions: Cancel or Immediate Send
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelSos,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _triggerSosNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: const Text('TRIGGER NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

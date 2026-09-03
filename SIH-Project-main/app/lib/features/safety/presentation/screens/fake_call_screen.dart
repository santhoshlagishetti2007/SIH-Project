import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Interactive Fake-Call Simulator to help discreetly exit uncomfortable situations
class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;
  final int delaySeconds;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Mom ❤️',
    this.callerNumber = '+91 98290 12345',
    this.delaySeconds = 0,
  });

  static Future<void> launch(
    BuildContext context, {
    String callerName = 'Mom ❤️',
    int delaySeconds = 0,
  }) async {
    if (delaySeconds > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📲 Fake call incoming in $delaySeconds seconds...'),
          duration: Duration(seconds: delaySeconds),
          behavior: SnackBarBehavior.floating,
        ),
      );
      await Future.delayed(Duration(seconds: delaySeconds));
    }

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => FakeCallScreen(
            callerName: callerName,
            delaySeconds: 0,
          ),
        ),
      );
    }
  }

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _isCallAnswered = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;
  bool _isSpeakerOn = true;
  bool _isMuted = false;

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  void _answerCall() {
    setState(() {
      _isCallAnswered = true;
    });

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: _isCallAnswered ? _buildActiveCallUI() : _buildIncomingCallUI(),
      ),
    );
  }

  Widget _buildIncomingCallUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top caller info
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 54, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.callerNumber,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ring_volume, color: Colors.greenAccent, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Incoming Phone Call...',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Accept / Decline Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decline Call Button
              Column(
                children: [
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53E3E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x66E53E3E), blurRadius: 16, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Decline', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),

              // Accept Call Button
              Column(
                children: [
                  GestureDetector(
                    onTap: _answerCall,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38A169),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x6638A169), blurRadius: 16, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top active call info
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDuration(_callDurationSeconds),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Conversational Prompt Cheat Sheet for the User
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_rounded, color: AppColors.accent, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Conversational Prompt (Read aloud):',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '"Yes, I can see your car outside! I\'m leaving right now, see you in 1 minute."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Active Call Controls Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallControl(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: 'Mute',
                    isActive: _isMuted,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _buildCallControl(
                    icon: Icons.dialpad,
                    label: 'Keypad',
                    isActive: false,
                    onTap: () {},
                  ),
                  _buildCallControl(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Speaker',
                    isActive: _isSpeakerOn,
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // End Call Button
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x66E53E3E), blurRadius: 18, spreadRadius: 3),
                    ],
                  ),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallControl({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.12),
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF0F172A) : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

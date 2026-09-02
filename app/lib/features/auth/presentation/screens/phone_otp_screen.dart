import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';

class PhoneOtpScreen extends ConsumerStatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  ConsumerState<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<PhoneOtpScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isCodeSent = false;
  String _verificationId = '';
  int _countdown = 60;
  Timer? _timer;
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final fullNumber = '$_selectedCountryCode$rawPhone';

    final success = await ref.read(authControllerProvider.notifier).sendPhoneOtp(
          phoneNumber: fullNumber,
          onCodeSent: (verId, resendToken) {
            setState(() {
              _isCodeSent = true;
              _verificationId = verId;
            });
            _startTimer();
            _focusNodes[0].requestFocus();
          },
          onVerificationFailed: (err) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(err), backgroundColor: AppColors.error),
            );
          },
        );

    // If dev mode without Firebase, allow instant transition to OTP screen with mock ID
    if (!success && mounted) {
      setState(() {
        _isCodeSent = true;
        _verificationId = 'mock-verification-id';
      });
      _startTimer();
    }
  }

  Future<void> _verifyOtp() async {
    final smsCode = _otpControllers.map((c) => c.text).join();
    if (smsCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    if (_verificationId == 'mock-verification-id') {
      // Dev test flow
      final rawPhone = _phoneController.text.trim();
      await ref.read(authControllerProvider.notifier).signInDevMock(
            email: 'traveler_$rawPhone@sanchari.app',
            displayName: 'Traveler ($rawPhone)',
          );
      return;
    }

    await ref.read(authControllerProvider.notifier).verifyPhoneOtp(
          verificationId: _verificationId,
          smsCode: smsCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCodeSent ? 'Verify Phone OTP' : 'Phone Sign In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isCodeSent) {
              setState(() {
                _isCodeSent = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Icon & Title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isCodeSent ? Icons.mark_email_read_outlined : Icons.phone_android_rounded,
                  color: AppColors.primaryLight,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _isCodeSent ? 'Enter 6-Digit Code' : 'Enter Your Phone Number',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text(
                _isCodeSent
                  ? 'We have sent a verification SMS to $_selectedCountryCode ${_phoneController.text.trim()}'
                  : 'We will send a 6-digit one-time password (OTP) via SMS to verify your mobile number.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              if (!_isCodeSent) ...[
                // Phone Number Input with Country Code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            items: const [
                              DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                              DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(value: '+61', child: Text('🇦🇺 +61')),
                              DropdownMenuItem(value: '+81', child: Text('🇯🇵 +81')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCountryCode = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: '9876543210',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Verification Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // 6 Digit OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 58,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (val.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          if (index == 5 && val.isNotEmpty) {
                            _verifyOtp();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Resend Timer & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _countdown > 0
                          ? 'Resend code in ${_countdown}s'
                          : 'Didn\'t receive code?',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: _countdown == 0 ? _sendOtp : null,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _countdown == 0
                              ? AppColors.primaryLight
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify & Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

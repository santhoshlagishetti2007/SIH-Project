import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'login_screen.dart';

class OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeText;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
  });
}

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      badgeText: 'AI TRAVEL BRAIN',
      title: 'Meet Your Intelligent Companion',
      subtitle:
          'Personalized itineraries, hidden gem recommendations, and 24/7 contextual travel assistance powered by Gemini AI.',
      icon: Icons.auto_awesome,
      accentColor: AppColors.accent,
    ),
    OnboardingSlide(
      badgeText: 'SAFETY FIRST',
      title: 'Travel Freely & Confidently',
      subtitle:
          'Dedicated safety features for solo wanderers, backpackers, and women travelers with automated emergency alerts and trusted safe zones.',
      icon: Icons.shield_rounded,
      accentColor: AppColors.secondary,
    ),
    OnboardingSlide(
      badgeText: 'REALTIME SYNC',
      title: 'Squad Journeys & Live Sharing',
      subtitle:
          'Realtime location sharing, collaborative travel budgets, and instant memory boards for solo or group adventures.',
      icon: Icons.share_location_rounded,
      accentColor: AppColors.primaryLight,
    ),
  ];

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand Logo & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.explore, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SANCHARI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle: Carousel Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Hero Icon Card
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                slide.accentColor.withOpacity(0.25),
                                slide.accentColor.withOpacity(0.02),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: slide.accentColor.withOpacity(0.35),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                slide.icon,
                                size: 54,
                                color: slide.accentColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: slide.accentColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            slide.badgeText,
                            style: TextStyle(
                              color: slide.accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls: Page Dots & Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                children: [
                  // Smooth Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _navigateToLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _slides.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
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
}

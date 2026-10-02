import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../core/constants/app_colors.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeText;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
  });
}

/// Interactive 3-slide Onboarding Screen
/// Clean Stateless Architecture using GetX reactive state (Obx) & OnboardingController.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Discover Latest Trends & Curated Tech',
      subtitle:
          'Explore thousands of handpicked items across smart devices, fashion, fragrances, and home decor from global brands.',
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.primary,
      badgeText: '10,000+ PRODUCTS',
    ),
    OnboardingItem(
      title: 'Seamless Shopping & Instant Favorites',
      subtitle:
          'Save your favorite picks with one tap, manage your cart effortlessly, and track real-time stock availability.',
      icon: Icons.favorite_rounded,
      accentColor: AppColors.secondary,
      badgeText: 'SMART CATALOG',
    ),
    OnboardingItem(
      title: 'Fast Checkout & Member Discounts',
      subtitle:
          'Unlock exclusive flash sales, up to 70% off selected items, and enjoy seamless doorstep delivery.',
      icon: Icons.local_fire_department_rounded,
      accentColor: AppColors.accent,
      badgeText: 'SPECIAL OFFERS',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Top App Bar with Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AuraStore',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: controller.finishOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Carousel (Responsive across all phone sizes)
                Expanded(
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemCount: _pages.length,
                    onPageChanged: controller.onPageChanged,
                    itemBuilder: (context, index) {
                      final item = _pages[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final h = constraints.maxHeight;
                          // Responsive sizing based on available viewport height
                          final outerCircleSize =
                              (h * 0.35).clamp(130.0, 220.0);
                          final innerCircleSize = outerCircleSize * 0.71;
                          final iconSize = outerCircleSize * 0.35;
                          final titleFontSize =
                              (h * 0.034).clamp(18.0, 24.0);
                          final subtitleFontSize =
                              (h * 0.021).clamp(12.5, 14.5);
                          final titleSpacing = (h * 0.02).clamp(8.0, 16.0);
                          final subtitleSpacing =
                              (h * 0.015).clamp(6.0, 12.0);

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      const Spacer(flex: 2),
                                      // Visual Graphic Card
                                      Container(
                                        width: outerCircleSize,
                                        height: outerCircleSize,
                                        decoration: BoxDecoration(
                                          color: item.accentColor
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: innerCircleSize,
                                            height: innerCircleSize,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: item.accentColor
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              item.icon,
                                              size: iconSize,
                                              color: item.accentColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(flex: 2),

                                      // Category Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: item.accentColor
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.badgeText,
                                          style: TextStyle(
                                            color: item.accentColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: titleSpacing),

                                      // Slide Title
                                      Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          height: 1.25,
                                        ),
                                      ),
                                      SizedBox(height: subtitleSpacing),

                                      // Slide Subtitle
                                      Text(
                                        item.subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: subtitleFontSize,
                                          color: AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                      const Spacer(flex: 3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom Navigation controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    children: [
                      // Smooth Page Indicators using Obx
                      Obx(() {
                        final currentIndex = controller.currentIndex;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            final isSelected = index == currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: isSelected ? 28 : 8,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Next / Get Started Action Button using Obx
                      Obx(() {
                        final isLastPage = controller.currentIndex == _pages.length - 1;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => controller.nextPage(_pages.length),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage ? 'Get Started' : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../core/constants/app_colors.dart';

/// Service managing the first-time user feature walkthrough using TutorialCoachMark
class TutorialService {
  static const String _prefKey = 'has_seen_main_tutorial_v1';

  /// Checks if tutorial has been shown previously
  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Marks tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  /// Resets tutorial flag (useful for testing or replay)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Displays the interactive feature tour if it's the user's first time
  static Future<void> showTutorialIfNeeded({
    required BuildContext context,
    required GlobalKey searchKey,
    required GlobalKey categoriesKey,
    required GlobalKey sortKey,
    required GlobalKey favoritesKey,
    required GlobalKey cartKey,
    required GlobalKey profileKey,
    bool force = false,
  }) async {
    if (!force) {
      final seen = await hasSeenTutorial();
      if (seen) return;
    }

    if (!context.mounted) return;

    final targets = _createTargets(
      searchKey: searchKey,
      categoriesKey: categoriesKey,
      sortKey: sortKey,
      favoritesKey: favoritesKey,
      cartKey: cartKey,
      profileKey: profileKey,
    );

    late TutorialCoachMark tutorialCoachMark;

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0F172A),
      opacityShadow: 0.85,
      paddingFocus: 8,
      hideSkip: true, // We provide our own styled Skip button inside content cards
      onFinish: () {
        markTutorialCompleted();
      },
      onSkip: () {
        markTutorialCompleted();
        return true;
      },
    );

    // Show after current frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        tutorialCoachMark.show(context: context);
      }
    });
  }

  static List<TargetFocus> _createTargets({
    required GlobalKey searchKey,
    required GlobalKey categoriesKey,
    required GlobalKey sortKey,
    required GlobalKey favoritesKey,
    required GlobalKey cartKey,
    required GlobalKey profileKey,
  }) {
    return [
      // 1. Search Bar Target
      TargetFocus(
        identify: 'search_bar_target',
        keyTarget: searchKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 1,
                totalSteps: 6,
                icon: Icons.search_rounded,
                title: 'Smart Product Search',
                description:
                    'Quickly discover items by keyword, brand, or tag with live debounced filtering.',
                controller: controller,
                isFirst: true,
              );
            },
          ),
        ],
      ),

      // 2. Categories Filter Target
      TargetFocus(
        identify: 'categories_target',
        keyTarget: categoriesKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 2,
                totalSteps: 6,
                icon: Icons.category_rounded,
                title: 'Category Explorer',
                description:
                    'Tap any category chip to filter the catalog instantly, or tap "All" to reset.',
                controller: controller,
              );
            },
          ),
        ],
      ),

      // 3. Sort Dropdown Target
      TargetFocus(
        identify: 'sort_target',
        keyTarget: sortKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 3,
                totalSteps: 6,
                icon: Icons.swap_vert_rounded,
                title: 'Sort & Organize',
                description:
                    'Sort products effortlessly by Price (Low/High), Customer Ratings, or Featured order.',
                controller: controller,
              );
            },
          ),
        ],
      ),

      // 4. Favorites Target
      TargetFocus(
        identify: 'favorites_target',
        keyTarget: favoritesKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 4,
                totalSteps: 6,
                icon: Icons.favorite_rounded,
                title: 'Wishlist & Favorites',
                description:
                    'Save your favorite products with one tap and review them anytime from here.',
                controller: controller,
              );
            },
          ),
        ],
      ),

      // 5. Shopping Cart Target
      TargetFocus(
        identify: 'cart_target',
        keyTarget: cartKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 5,
                totalSteps: 6,
                icon: Icons.shopping_bag_rounded,
                title: 'Real-Time Cart',
                description:
                    'Review your cart items, adjust quantities, calculate totals, and proceed to checkout.',
                controller: controller,
              );
            },
          ),
        ],
      ),

      // 6. User Profile Target
      TargetFocus(
        identify: 'profile_target',
        keyTarget: profileKey,
        alignSkip: Alignment.bottomRight,
        shape: ShapeLightFocus.Circle,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildTutorialCard(
                step: 6,
                totalSteps: 6,
                icon: Icons.person_rounded,
                title: 'Profile & Account',
                description:
                    'Manage your session, view your credentials, or sign in/out anytime.',
                controller: controller,
                isLast: true,
              );
            },
          ),
        ],
      ),
    ];
  }

  /// Builds a modern, glassmorphic tutorial dialog card with clear navigation controls
  static Widget _buildTutorialCard({
    required int step,
    required int totalSteps,
    required IconData icon,
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step $step of $totalSteps',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => controller.skip(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isFirst)
                TextButton(
                  onPressed: () => controller.previous(),
                  child: const Text(
                    'Previous',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => controller.skip(),
                  child: const Text(
                    'Skip Tour',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () {
                  if (isLast) {
                    controller.next();
                  } else {
                    controller.next();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  isLast ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                ),
                label: Text(
                  isLast ? 'Got it!' : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

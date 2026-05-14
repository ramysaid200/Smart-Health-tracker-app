import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/theme/text_styles.dart';
import 'app_router.dart';

/// Bottom navigation bar with 5 tabs + FAB quick-action
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
  });

  final int currentIndex;
  final Widget body;

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', route: AppRouter.home),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Nutrition', route: AppRouter.nutrition),
    _NavItem(icon: Icons.add, label: '', route: ''), // FAB placeholder
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Workouts', route: AppRouter.workouts),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', route: AppRouter.profile),
  ];

  void _navigate(BuildContext context, int index) {
    if (index == 2) {
      _showQuickActions(context);
      return;
    }
    if (index == currentIndex) return;
    final route = _items[index].route;
    Navigator.pushReplacementNamed(context, route);
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.cardRadius)),
      ),
      builder: (ctx) => _QuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: AppDimensions.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          if (i == 2) return const Expanded(child: SizedBox()); // FAB space
          final item = _items[i];
          final isActive = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _navigate(context, i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryGlow : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(
                      item.icon,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      size: AppDimensions.iconLg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQuickActions(context),
      child: Container(
        width: AppDimensions.fabSize,
        height: AppDimensions.fabSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

class _QuickActionSheet extends StatelessWidget {
  final List<Map<String, dynamic>> _actions = [
    {'icon': Icons.water_drop_rounded, 'label': 'Add Water', 'color': AppColors.waterColor, 'route': AppRouter.water},
    {'icon': Icons.restaurant_rounded, 'label': 'Log Meal', 'color': AppColors.nutritionColor, 'route': AppRouter.addMeal},
    {'icon': Icons.fitness_center_rounded, 'label': 'Log Workout', 'color': AppColors.workoutColor, 'route': AppRouter.addWorkout},
    {'icon': Icons.monitor_weight_rounded, 'label': 'Add Weight', 'color': AppColors.weightColor, 'route': AppRouter.addWeight},
    {'icon': Icons.bedtime_rounded, 'label': 'Log Sleep', 'color': AppColors.sleepColor, 'route': AppRouter.addSleep},
    {'icon': Icons.favorite_rounded, 'label': 'Add Vitals', 'color': AppColors.heartColor, 'route': AppRouter.addVitals},
  ];

  _QuickActionSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Quick Add', style: AppTextStyles.h4),
          const SizedBox(height: AppDimensions.xl),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: AppDimensions.sm,
            mainAxisSpacing: AppDimensions.sm,
            childAspectRatio: 1.1,
            children: _actions.map((a) {
              final color = a['color'] as Color;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, a['route'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a['icon'] as IconData, color: color, size: 28),
                      const SizedBox(height: AppDimensions.xs),
                      Text(a['label'] as String, style: AppTextStyles.labelSm, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}

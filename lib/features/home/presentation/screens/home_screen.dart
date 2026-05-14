import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/section_header.dart';
import '../../../../../navigation/app_router.dart';
import '../../../../../navigation/bottom_nav_bar.dart';

/// Main home dashboard screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<HomeProvider>().loadTodaySummary();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: home.loadTodaySummary,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppDimensions.base),
                      if (home.isLoading) const LoadingIndicator() else ...[
                        _buildQuickStats(context, home),
                        const SizedBox(height: AppDimensions.xl),
                        _buildOverallProgress(context, home),
                        const SizedBox(height: AppDimensions.xl),
                        _buildQuickActions(context, home),
                        const SizedBox(height: AppDimensions.xl),
                        _buildTodaySummary(context, home),
                        const SizedBox(height: AppDimensions.massive),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name.split(' ').first ?? 'there';
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.xl,
        AppDimensions.screenPadding,
        AppDimensions.base,
      ),
      child: FadeInDown(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormatter.getGreeting(name), style: AppTextStyles.greeting),
                  Text(DateFormatter.toDisplayDate(DateTime.now()), style: AppTextStyles.greetingSubtitle),
                ],
              ),
            ),
            Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRouter.profile),
                  child: Container(
                    width: AppDimensions.avatarLg,
                    height: AppDimensions.avatarLg,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.primaryGradient),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'Y',
                        style: AppTextStyles.h3.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, HomeProvider home) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Today's Stats"),
          const SizedBox(height: AppDimensions.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatCard(
                  icon: Icons.directions_walk_rounded,
                  color: AppColors.stepsColor,
                  label: 'Steps',
                  value: home.currentSteps.toString(),
                  goal: home.stepsGoal.toString(),
                  progress: home.stepsGoal > 0 ? home.currentSteps / home.stepsGoal : 0,
                  onTap: () => Navigator.pushNamed(context, AppRouter.steps),
                ),
                const SizedBox(width: AppDimensions.sm),
                _StatCard(
                  icon: Icons.water_drop_rounded,
                  color: AppColors.waterColor,
                  label: 'Water',
                  value: home.currentWaterGlasses.toString(),
                  goal: '${home.waterGoal} glasses',
                  progress: home.waterGoal > 0 ? home.currentWaterGlasses / home.waterGoal : 0,
                  onTap: () => Navigator.pushNamed(context, AppRouter.water),
                ),
                const SizedBox(width: AppDimensions.sm),
                _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.caloriesColor,
                  label: 'Calories',
                  value: home.currentCalories.toStringAsFixed(0),
                  goal: '${home.calorieGoal} kcal',
                  progress: home.calorieGoal > 0 ? home.currentCalories / home.calorieGoal : 0,
                  onTap: () => Navigator.pushNamed(context, AppRouter.nutrition),
                ),
                const SizedBox(width: AppDimensions.sm),
                _StatCard(
                  icon: Icons.bedtime_rounded,
                  color: AppColors.sleepColor,
                  label: 'Sleep',
                  value: home.sleep != null
                      ? '${home.sleep!.durationHours.toStringAsFixed(1)}h'
                      : '—',
                  goal: 'Goal: 8h',
                  progress: home.sleep != null ? (home.sleep!.durationHours / 8).clamp(0, 1) : 0,
                  onTap: () => Navigator.pushNamed(context, AppRouter.sleep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context, HomeProvider home) {
    final progress = home.overallProgress;
    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1535), Color(0xFF0F1623)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            _ProgressRingWidget(progress: progress),
            const SizedBox(width: AppDimensions.xl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Progress', style: AppTextStyles.h4),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% of your daily goals complete',
                    style: AppTextStyles.bodyMdSecondary,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _ProgressMini(label: 'Steps', value: home.currentSteps / home.stepsGoal, color: AppColors.stepsColor),
                  _ProgressMini(label: 'Water', value: home.currentWaterGlasses / home.waterGoal, color: AppColors.waterColor),
                  _ProgressMini(
                    label: 'Calories',
                    value: home.calorieGoal > 0 ? (home.currentCalories / home.calorieGoal) : 0,
                    color: AppColors.caloriesColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, HomeProvider home) {
    final actions = [
      {'label': 'Add Water', 'icon': Icons.water_drop_rounded, 'color': AppColors.waterColor, 'route': AppRouter.water},
      {'label': 'Log Meal', 'icon': Icons.restaurant_rounded, 'color': AppColors.nutritionColor, 'route': AppRouter.addMeal},
      {'label': 'Log Workout', 'icon': Icons.fitness_center_rounded, 'color': AppColors.workoutColor, 'route': AppRouter.addWorkout},
      {'label': 'Add Weight', 'icon': Icons.monitor_weight_rounded, 'color': AppColors.weightColor, 'route': AppRouter.addWeight},
      {'label': 'Medication', 'icon': Icons.medication_rounded, 'color': AppColors.error, 'route': AppRouter.medications},
      {'label': 'Analytics', 'icon': Icons.bar_chart_rounded, 'color': AppColors.primary, 'route': AppRouter.analytics},
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppDimensions.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.sm,
            mainAxisSpacing: AppDimensions.sm,
            childAspectRatio: 1.0,
            children: actions.map((a) {
              final color = a['color'] as Color;
              return GestureDetector(
                onTap: () {
                  if (a['label'] == 'Add Water') {
                    home.quickAddWater();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('💧 +1 glass added!'), duration: Duration(seconds: 1)),
                    );
                  } else {
                    Navigator.pushNamed(context, a['route'] as String);
                  }
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
                      Icon(a['icon'] as IconData, color: color, size: AppDimensions.iconXl),
                      const SizedBox(height: AppDimensions.xs),
                      Text(a['label'] as String, style: AppTextStyles.labelSm, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, HomeProvider home) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: "Today's Summary", actionLabel: 'View All', onAction: () => Navigator.pushNamed(context, AppRouter.analytics)),
          const SizedBox(height: AppDimensions.sm),
          _SummaryItem(icon: '🚶', title: '${home.currentSteps} steps walked', time: 'Today'),
          _SummaryItem(icon: '💧', title: '${home.currentWaterGlasses} glasses of water', time: 'Today'),
          _SummaryItem(icon: '🍽️', title: '${home.currentCalories.toStringAsFixed(0)} kcal consumed', time: 'Today'),
          if (home.sleep != null)
            _SummaryItem(
              icon: '🌙',
              title: '${home.sleep!.durationHours.toStringAsFixed(1)}h of sleep (${home.sleep!.quality})',
              time: 'Last night',
            ),
          if (home.latestWeight != null)
            _SummaryItem(icon: '⚖️', title: '${home.latestWeight!.weight} ${home.latestWeight!.unit}', time: 'Latest'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.goal,
    required this.progress,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String goal;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppDimensions.iconMd),
                const Spacer(),
                Text('${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%', style: AppTextStyles.labelSm.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(value, style: AppTextStyles.metricSm.copyWith(color: color)),
            Text(goal, style: AppTextStyles.bodyXs),
            const SizedBox(height: AppDimensions.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingWidget extends StatefulWidget {
  const _ProgressRingWidget({required this.progress});
  final double progress;

  @override
  State<_ProgressRingWidget> createState() => _ProgressRingWidgetState();
}

class _ProgressRingWidgetState extends State<_ProgressRingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(painter: _RingPainter(_anim.value), size: const Size(100, 100)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(_anim.value * 100).toStringAsFixed(0)}%', style: AppTextStyles.metricSm.copyWith(color: AppColors.primary)),
                Text('done', style: AppTextStyles.bodyXs),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 8;
    const stroke = 10.0;
    final bgPaint = Paint()..color = AppColors.borderSubtle..strokeWidth = stroke..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..shader = const LinearGradient(colors: AppColors.primaryGradient).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress.clamp(0, 1),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _ProgressMini extends StatelessWidget {
  const _ProgressMini({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 56, child: Text(label, style: AppTextStyles.bodyXs)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.title, required this.time});
  final String icon;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.cardPadding,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppDimensions.sm),
          Expanded(child: Text(title, style: AppTextStyles.bodyMd)),
          Text(time, style: AppTextStyles.bodySmSecondary),
        ],
      ),
    );
  }
}

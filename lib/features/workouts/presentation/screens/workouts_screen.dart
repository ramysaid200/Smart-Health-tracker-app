import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../navigation/bottom_nav_bar.dart';
import '../../../../../navigation/app_router.dart';

/// Workouts screen with history and week summary
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WorkoutProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3,
      body: Consumer<WorkoutProvider>(
        builder: (_, p, __) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Workouts'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addWorkout).then((_) => p.load())),
            ],
          ),
          body: p.isLoading
              ? const LoadingIndicator()
              : RefreshIndicator(
                  color: AppColors.workoutColor,
                  onRefresh: p.load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    child: Column(children: [
                      FadeInDown(child: _buildWeekSummary(p)),
                      const SizedBox(height: AppDimensions.xl),
                      if (p.workouts.isEmpty)
                        EmptyStateWidget(
                          title: 'No workouts yet',
                          subtitle: 'Start logging your workouts to track progress',
                          icon: Icons.fitness_center_rounded,
                          color: AppColors.workoutColor,
                          actionLabel: 'Log Workout',
                          onAction: () => Navigator.pushNamed(context, AppRouter.addWorkout).then((_) => p.load()),
                        )
                      else
                        FadeInUp(child: _buildList(context, p)),
                      const SizedBox(height: AppDimensions.massive),
                    ]),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWeekSummary(WorkoutProvider p) {
    final weekWorkouts = p.workouts.where((w) => DateTime.now().difference(w.date).inDays <= 7).toList();
    final totalMinutes = weekWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
    final totalCalories = weekWorkouts.fold(0.0, (sum, w) => sum + w.caloriesBurned);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1535), Color(0xFF0F1623)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('This Week', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.base),
        Row(children: [
          _WeekStat(label: 'Workouts', value: '${weekWorkouts.length}', icon: Icons.fitness_center_rounded, color: AppColors.workoutColor),
          _WeekStat(label: 'Time', value: '${(totalMinutes ~/ 60)}h ${totalMinutes % 60}m', icon: Icons.timer_rounded, color: AppColors.primary),
          _WeekStat(label: 'Burned', value: '${totalCalories.toStringAsFixed(0)}', icon: Icons.local_fire_department_rounded, color: AppColors.caloriesColor),
        ]),
      ]),
    );
  }

  Widget _buildList(BuildContext context, WorkoutProvider p) {
    final workoutIcons = {'running': '🏃', 'walking': '🚶', 'cycling': '🚴', 'swimming': '🏊', 'strength': '🏋️', 'yoga': '🧘', 'hiit': '⚡'};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.sm),
        ...p.workouts.map((w) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
          child: Row(children: [
            Text(workoutIcons[w.type] ?? '💪', style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.type.toUpperCase(), style: AppTextStyles.h5),
              Text('${w.durationMinutes}min • ${w.caloriesBurned.toStringAsFixed(0)} kcal • ${w.intensity}', style: AppTextStyles.bodySmSecondary),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_formatDate(w.date), style: AppTextStyles.labelSm),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: AppDimensions.iconMd),
                onPressed: () => p.deleteWorkout(w.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ]),
          ]),
        )),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _WeekStat extends StatelessWidget {
  const _WeekStat({required this.label, required this.value, required this.icon, required this.color});
  final String label; final String value; final IconData icon; final Color color;

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, color: color, size: AppDimensions.iconXl),
    const SizedBox(height: AppDimensions.xs),
    Text(value, style: AppTextStyles.metricSm.copyWith(color: color)),
    Text(label, style: AppTextStyles.bodySmSecondary),
  ]));
}

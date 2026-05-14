import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../navigation/app_router.dart';

/// Sleep tracking screen
class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});
  @override State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SleepProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addSleep).then((_) => context.read<SleepProvider>().load()))],
      ),
      body: Consumer<SleepProvider>(
        builder: (_, p, __) => p.isLoading
            ? const LoadingIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(children: [
                  _buildLatestCard(p),
                  const SizedBox(height: AppDimensions.xl),
                  _buildWeekChart(p),
                  const SizedBox(height: AppDimensions.xl),
                  _buildInsights(p),
                ]),
              ),
      ),
    );
  }

  Widget _buildLatestCard(SleepProvider p) {
    if (p.latest == null) return EmptyStateWidget(title: 'No sleep data', subtitle: 'Tap + to log last night\'s sleep', icon: Icons.bedtime_rounded, color: AppColors.sleepColor, actionLabel: 'Log Sleep', onAction: () => Navigator.pushNamed(context, AppRouter.addSleep));
    final s = p.latest!;
    final qualityColor = {'poor': AppColors.sleepPoor, 'fair': AppColors.sleepFair, 'good': AppColors.sleepGood, 'excellent': AppColors.sleepExcellent}[s.quality] ?? AppColors.sleepColor;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1535), Color(0xFF0F1623)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: [
        const Icon(Icons.bedtime_rounded, color: AppColors.sleepColor, size: 48),
        const SizedBox(height: AppDimensions.sm),
        Text('Last night', style: AppTextStyles.bodyMdSecondary),
        Text('${s.durationHours.toStringAsFixed(1)}h', style: AppTextStyles.metricLg.copyWith(color: AppColors.sleepColor)),
        const SizedBox(height: AppDimensions.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.base, vertical: AppDimensions.xs),
          decoration: BoxDecoration(color: qualityColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
          child: Text(s.quality.toUpperCase(), style: AppTextStyles.labelSm.copyWith(color: qualityColor)),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🌙 ${_formatTime(s.bedtime)}', style: AppTextStyles.bodyMdSecondary),
          const Text('  →  ', style: TextStyle(color: AppColors.textSecondary)),
          Text('☀️ ${_formatTime(s.wakeTime)}', style: AppTextStyles.bodyMdSecondary),
        ]),
      ]),
    );
  }

  Widget _buildWeekChart(SleepProvider p) {
    if (p.weekLogs.isEmpty) return const SizedBox.shrink();
    final logs = p.weekLogs.reversed.take(7).toList();
    final qualityColors = {'poor': AppColors.sleepPoor, 'fair': AppColors.sleepFair, 'good': AppColors.sleepGood, 'excellent': AppColors.sleepExcellent};

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('7-Night Overview', style: AppTextStyles.h5),
        const SizedBox(height: AppDimensions.base),
        SizedBox(
          height: 160,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 10,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                if (v.toInt() >= logs.length) return const SizedBox.shrink();
                return Text(logs[v.toInt()].date.substring(5, 10), style: AppTextStyles.chartLabel);
              })),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: logs.asMap().entries.map((e) {
              final log = e.value;
              return BarChartGroupData(x: e.key, barRods: [BarChartRodData(
                toY: log.durationHours.clamp(0, 12),
                color: qualityColors[log.quality] ?? AppColors.sleepColor,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              )]);
            }).toList(),
          ), duration: const Duration(milliseconds: 600)),
        ),
      ]),
    );
  }

  Widget _buildInsights(SleepProvider p) {
    if (p.weekLogs.isEmpty) return const SizedBox.shrink();
    final avg = p.weekLogs.fold(0.0, (sum, l) => sum + l.durationHours) / p.weekLogs.length;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.sleepColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.sleepColor.withValues(alpha: 0.2))),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 24)),
        const SizedBox(width: AppDimensions.sm),
        Expanded(child: Text('You averaged ${avg.toStringAsFixed(1)} hours this week. ${avg >= 7 ? 'Great job! 🎉' : 'Try to get at least 7 hours.'}', style: AppTextStyles.bodyMd)),
      ]),
    );
  }

  String _formatTime(DateTime dt) => '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour < 12 ? 'AM' : 'PM'}';
}

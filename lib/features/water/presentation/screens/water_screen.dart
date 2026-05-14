import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/water_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/section_header.dart';
import '../../../../../navigation/bottom_nav_bar.dart';

/// Water intake tracking screen
class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WaterProvider>().loadToday());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<WaterProvider>(
        builder: (context, p, _) {
          if (p.isLoading) return const LoadingIndicator();
          return RefreshIndicator(
            color: AppColors.waterColor,
            onRefresh: p.loadToday,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  FadeInDown(child: _buildWaterGlass(p)),
                  const SizedBox(height: AppDimensions.xl),
                  FadeInUp(delay: const Duration(milliseconds: 100), child: _buildQuickAdd(context, p)),
                  const SizedBox(height: AppDimensions.xl),
                  FadeInUp(delay: const Duration(milliseconds: 200), child: _buildWeekChart(p)),
                  const SizedBox(height: AppDimensions.xl),
                  FadeInUp(delay: const Duration(milliseconds: 300), child: _buildLog(p)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterGlass(WaterProvider p) {
    final progress = (p.glasses / p.goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text('${p.glasses} / ${p.goal} glasses', style: AppTextStyles.metricLg.copyWith(color: AppColors.waterColor)),
          const SizedBox(height: AppDimensions.sm),
          Text('${(progress * 100).toStringAsFixed(0)}% of daily goal', style: AppTextStyles.bodyMdSecondary),
          const SizedBox(height: AppDimensions.xl),
          // Water glass visualization
          SizedBox(
            width: 80,
            height: 140,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 80,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.waterColor.withValues(alpha: 0.4), width: 2),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 76,
                  height: 136 * progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.waterColor.withValues(alpha: 0.4), AppColors.waterColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd(BuildContext context, WaterProvider p) {
    final amounts = [{'ml': 150, 'label': '150ml'}, {'ml': 250, 'label': '250ml'}, {'ml': 500, 'label': '500ml'}, {'ml': 750, 'label': '750ml'}];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Add'),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: amounts.map((a) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () => p.addWater(a['ml'] as int),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.waterColor.withValues(alpha: 0.15),
                    foregroundColor: AppColors.waterColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                  ),
                  child: Text(a['label'] as String, style: AppTextStyles.buttonSm.copyWith(color: AppColors.waterColor)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeekChart(WaterProvider p) {
    final data = p.weekData;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('7-Day Overview', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.base),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (p.goal * 1.2).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(data[v.toInt()]['label'] as String? ?? '', style: AppTextStyles.chartLabel))),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) {
                  final glasses = (e.value['glasses'] as num?)?.toDouble() ?? 0;
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(
                      toY: glasses,
                      color: glasses >= p.goal ? AppColors.success : AppColors.waterColor,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ]);
                }).toList(),
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLog(WaterProvider p) {
    if (p.logs.isEmpty) {
      return EmptyStateWidget(
        title: 'No logs yet',
        subtitle: 'Tap a button above to log your water intake',
        icon: Icons.water_drop_outlined,
        color: AppColors.waterColor,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Today's Log"),
        const SizedBox(height: AppDimensions.sm),
        ...p.logs.reversed.take(10).map((log) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.cardPadding, vertical: AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: AppColors.waterColor, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: Text('${log['amount']}ml', style: AppTextStyles.bodyMd)),
              Text(log['time'] as String? ?? '', style: AppTextStyles.bodySmSecondary),
            ],
          ),
        )),
      ],
    );
  }
}

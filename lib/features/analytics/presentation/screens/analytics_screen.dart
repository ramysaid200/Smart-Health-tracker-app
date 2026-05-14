import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../navigation/app_router.dart';

/// Analytics screen with selectable metrics and time range
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedMetric = 'steps';
  String _timeRange = 'week';

  static const _metrics = ['steps', 'water', 'sleep', 'weight'];
  static const _ranges = ['week', 'month', '3 months', 'year'];

  final _metricColors = {'steps': AppColors.stepsColor, 'water': AppColors.waterColor, 'sleep': AppColors.sleepColor, 'weight': AppColors.weightColor};
  final _insights = [
    '📈 Track your progress consistently for better insights',
    '💧 Staying hydrated boosts energy and focus',
    '🚶 Regular walking improves cardiovascular health',
    '😴 7-9 hours of sleep is optimal for most adults',
    '⚖️ Small weight changes over time lead to big results',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildMetricSelector(),
          const SizedBox(height: AppDimensions.base),
          _buildTimeRangeSelector(),
          const SizedBox(height: AppDimensions.xl),
          _buildChart(),
          const SizedBox(height: AppDimensions.xl),
          _buildStats(),
          const SizedBox(height: AppDimensions.xl),
          _buildInsights(),
        ]),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Metric', style: AppTextStyles.h5),
        const SizedBox(height: AppDimensions.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _metrics.map((m) {
              final isSelected = _selectedMetric == m;
              final color = _metricColors[m] ?? AppColors.primary;
              return GestureDetector(
                onTap: () => setState(() => _selectedMetric = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: AppDimensions.sm),
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.base, vertical: AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
                    border: Border.all(color: isSelected ? color : AppColors.borderSubtle, width: isSelected ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(m.toUpperCase().substring(0, 1) + m.substring(1), style: AppTextStyles.labelMd.copyWith(color: isSelected ? color : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: _ranges.map((r) {
        final isSelected = _timeRange == r;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _timeRange = r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderSubtle),
            ),
            child: Text(r, style: AppTextStyles.labelSm.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary), textAlign: TextAlign.center),
          ),
        ));
      }).toList(),
    );
  }

  Widget _buildChart() {
    final color = _metricColors[_selectedMetric] ?? AppColors.primary;
    // Generate sample spot data for visualization
    final spotCount = _timeRange == 'week' ? 7 : _timeRange == 'month' ? 30 : _timeRange == '3 months' ? 12 : 12;
    final spots = List.generate(spotCount, (i) => FlSpot(i.toDouble(), (20 + (i * 3 % 15)).toDouble()));

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${_selectedMetric.toUpperCase().substring(0, 1)}${_selectedMetric.substring(1)} — $_timeRange', style: AppTextStyles.h5),
        ]),
        const SizedBox(height: AppDimensions.base),
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(
            gridData: FlGridData(show: true, getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderSubtle, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
            )],
          ), duration: const Duration(milliseconds: 800)),
        ),
      ]),
    );
  }

  Widget _buildStats() {
    final color = _metricColors[_selectedMetric] ?? AppColors.primary;
    return Row(children: [
      Expanded(child: _StatBox(label: 'Average', value: '—', color: color)),
      const SizedBox(width: AppDimensions.sm),
      Expanded(child: _StatBox(label: 'Min', value: '—', color: AppColors.info)),
      const SizedBox(width: AppDimensions.sm),
      Expanded(child: _StatBox(label: 'Max', value: '—', color: AppColors.success)),
      const SizedBox(width: AppDimensions.sm),
      Expanded(child: _StatBox(label: 'Total', value: '—', color: AppColors.warning)),
    ]);
  }

  Widget _buildInsights() {
    final insight = _insights[_metrics.indexOf(_selectedMetric) % _insights.length];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(AppDimensions.cardRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Insights', style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
        const SizedBox(height: AppDimensions.sm),
        Text(insight, style: AppTextStyles.bodyMd),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.color});
  final String label; final String value; final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.sm),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
    child: Column(children: [
      Text(label, style: AppTextStyles.labelSm),
      const SizedBox(height: AppDimensions.xs),
      Text(value, style: AppTextStyles.metricSm.copyWith(color: color, fontSize: 16)),
    ]),
  );
}

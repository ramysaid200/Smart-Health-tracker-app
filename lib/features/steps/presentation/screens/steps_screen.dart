import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/section_header.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../navigation/app_router.dart';

/// Steps tracking screen
class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});
  @override State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  final _stepsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<StepsProvider>().loadToday());
  }

  @override
  void dispose() { _stepsCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steps'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showLogDialog(context),
          ),
        ],
      ),
      body: Consumer<StepsProvider>(
        builder: (_, p, __) {
          if (p.isLoading) return const LoadingIndicator();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              children: [
                _buildHeader(p),
                const SizedBox(height: AppDimensions.xl),
                _buildChart(p),
                const SizedBox(height: AppDimensions.xl),
                _buildStats(p),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(StepsProvider p) {
    final progress = (p.steps / p.goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text('${p.steps}', style: AppTextStyles.metricXl.copyWith(color: AppColors.stepsColor)),
          Text('of ${p.goal} steps', style: AppTextStyles.bodyMdSecondary),
          const SizedBox(height: AppDimensions.base),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.stepsColor.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.stepsColor),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text('${(progress * 100).toStringAsFixed(0)}% complete', style: AppTextStyles.labelMd.copyWith(color: AppColors.stepsColor)),
        ],
      ),
    );
  }

  Widget _buildChart(StepsProvider p) {
    final data = p.weekData;
    if (data.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Steps', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.base),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: p.goal.toDouble() * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(data[v.toInt()]['label'] as String? ?? '', style: AppTextStyles.chartLabel))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((e) {
                final steps = (e.value['steps'] as num?)?.toDouble() ?? 0;
                return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: steps, color: steps >= p.goal ? AppColors.success : AppColors.stepsColor, width: 20, borderRadius: BorderRadius.circular(4))]);
              }).toList(),
            ), duration: const Duration(milliseconds: 600)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(StepsProvider p) {
    return Row(children: [
      Expanded(child: _StatTile(label: 'Today', value: '${p.steps}', unit: 'steps', color: AppColors.stepsColor)),
      const SizedBox(width: AppDimensions.sm),
      Expanded(child: _StatTile(label: 'Goal', value: '${p.goal}', unit: 'steps', color: AppColors.success)),
      const SizedBox(width: AppDimensions.sm),
      Expanded(child: _StatTile(label: 'Calories', value: '${(p.steps * 0.04).toStringAsFixed(0)}', unit: 'kcal', color: AppColors.caloriesColor)),
    ]);
  }

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Steps'),
        content: TextField(
          controller: _stepsCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 8000', labelText: 'Steps count'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(_stepsCtrl.text);
              if (count != null) context.read<StepsProvider>().logSteps(count);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.unit, required this.color});
  final String label; final String value; final String unit; final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppDimensions.cardPadding),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
    child: Column(children: [
      Text(label, style: AppTextStyles.labelMd),
      const SizedBox(height: AppDimensions.xs),
      Text(value, style: AppTextStyles.metricSm.copyWith(color: color)),
      Text(unit, style: AppTextStyles.bodySmSecondary),
    ]),
  );
}

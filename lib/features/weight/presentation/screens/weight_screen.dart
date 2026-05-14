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
import '../../../../../core/utils/health_calculators.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../navigation/app_router.dart';

/// Weight tracking screen with trend chart and BMI
class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});
  @override State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WeightProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addWeight).then((_) => context.read<WeightProvider>().load()))],
      ),
      body: Consumer<WeightProvider>(
        builder: (_, p, __) => p.isLoading
            ? const LoadingIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(children: [
                  if (p.latest != null) _buildCurrentCard(p),
                  if (p.latest == null) EmptyStateWidget(title: 'No weight entries', subtitle: 'Tap + to log your weight', icon: Icons.monitor_weight_rounded, color: AppColors.weightColor, actionLabel: 'Log Weight', onAction: () => Navigator.pushNamed(context, AppRouter.addWeight)),
                  const SizedBox(height: AppDimensions.xl),
                  if (p.logs.length > 1) _buildChart(p),
                  const SizedBox(height: AppDimensions.xl),
                  if (p.logs.isNotEmpty) _buildHistory(p),
                ]),
              ),
      ),
    );
  }

  Widget _buildCurrentCard(WeightProvider p) {
    final w = p.latest!;
    final heightCm = StorageService.instance.userHeight;
    final bmi = HealthCalculators.calculateBMI(w.weight, heightCm);
    final bmiCategory = HealthCalculators.getBMICategory(bmi);
    final bmiColors = {'Underweight': AppColors.bmiUnderweight, 'Normal': AppColors.bmiNormal, 'Overweight': AppColors.bmiOverweight, 'Obese': AppColors.bmiObese};
    final bmiColor = bmiColors[bmiCategory] ?? AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A2535), Color(0xFF0F1623)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: [
        Text('${w.weight} ${w.unit}', style: AppTextStyles.metricLg.copyWith(color: AppColors.weightColor)),
        const SizedBox(height: AppDimensions.sm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('BMI: ${bmi.toStringAsFixed(1)}  ', style: AppTextStyles.bodyMd),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 2),
            decoration: BoxDecoration(color: bmiColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
            child: Text(bmiCategory, style: AppTextStyles.labelSm.copyWith(color: bmiColor)),
          ),
        ]),
        if (p.logs.length > 1) ...[
          const SizedBox(height: AppDimensions.sm),
          _buildChangeBadge(p),
        ],
      ]),
    );
  }

  Widget _buildChangeBadge(WeightProvider p) {
    final change = p.logs.last.weight - p.logs.first.weight;
    final isLoss = change < 0;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(isLoss ? Icons.trending_down_rounded : Icons.trending_up_rounded, color: isLoss ? AppColors.success : AppColors.caloriesColor, size: AppDimensions.iconMd),
      Text(' ${change.abs().toStringAsFixed(1)} ${p.logs.last.unit} since start', style: AppTextStyles.bodyMdSecondary.copyWith(color: isLoss ? AppColors.success : AppColors.caloriesColor)),
    ]);
  }

  Widget _buildChart(WeightProvider p) {
    final logs = p.logs.take(30).toList();
    final spots = logs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();
    final minY = logs.map((l) => l.weight).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = logs.map((l) => l.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Weight Trend', style: AppTextStyles.h5),
        const SizedBox(height: AppDimensions.base),
        SizedBox(
          height: 180,
          child: LineChart(LineChartData(
            minY: minY, maxY: maxY,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.weightColor,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.weightColor.withValues(alpha: 0.1)),
            )],
          ), duration: const Duration(milliseconds: 800)),
        ),
      ]),
    );
  }

  Widget _buildHistory(WeightProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.sm),
        ...p.logs.reversed.take(10).map((l) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.cardPadding, vertical: AppDimensions.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusMd), border: Border.all(color: AppColors.borderSubtle)),
          child: Row(children: [
            const Icon(Icons.monitor_weight_outlined, color: AppColors.weightColor),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text('${l.weight} ${l.unit}', style: AppTextStyles.bodyMd)),
            Text(_formatDate(l.date), style: AppTextStyles.bodySmSecondary),
          ]),
        )),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

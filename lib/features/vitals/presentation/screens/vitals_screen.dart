import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/utils/health_calculators.dart';
import '../../../../../navigation/app_router.dart';

/// Vitals screen – heart rate and blood pressure
class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<VitalsProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitals'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addVitals).then((_) => context.read<VitalsProvider>().load()))],
      ),
      body: Consumer<VitalsProvider>(
        builder: (_, p, __) => p.isLoading
            ? const LoadingIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(children: [
                  if (p.latest == null)
                    EmptyStateWidget(title: 'No vitals recorded', subtitle: 'Tap + to record heart rate or blood pressure', icon: Icons.favorite_rounded, color: AppColors.heartColor, actionLabel: 'Add Vitals', onAction: () => Navigator.pushNamed(context, AppRouter.addVitals))
                  else ...[
                    _buildHRCard(p.latest!),
                    const SizedBox(height: AppDimensions.base),
                    if (p.latest!.systolic != null) _buildBPCard(p.latest!),
                    const SizedBox(height: AppDimensions.xl),
                    _buildHistory(p),
                  ],
                ]),
              ),
      ),
    );
  }

  Widget _buildHRCard(VitalsLogModel v) {
    if (v.heartRate == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.heartColor.withValues(alpha: 0.3))),
      child: Row(children: [
        const _PulsingHeart(),
        const SizedBox(width: AppDimensions.base),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Heart Rate', style: AppTextStyles.labelLg),
          Text('${v.heartRate} bpm', style: AppTextStyles.metricMd.copyWith(color: AppColors.heartColor)),
        ]),
      ]),
    );
  }

  Widget _buildBPCard(VitalsLogModel v) {
    final status = HealthCalculators.classifyBloodPressure(v.systolic!, v.diastolic!);
    final statusColors = {'Normal': AppColors.success, 'Elevated': AppColors.warning, 'High Stage 1': AppColors.caloriesColor, 'High Stage 2': AppColors.error};
    final color = statusColors[status] ?? AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Icon(Icons.favorite_border_rounded, color: color, size: AppDimensions.iconXl),
        const SizedBox(width: AppDimensions.base),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Blood Pressure', style: AppTextStyles.labelLg),
          Text('${v.systolic}/${v.diastolic} mmHg', style: AppTextStyles.metricMd.copyWith(color: color)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
          child: Text(status, style: AppTextStyles.labelSm.copyWith(color: color)),
        ),
      ]),
    );
  }

  Widget _buildHistory(VitalsProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: AppTextStyles.h4),
        const SizedBox(height: AppDimensions.sm),
        ...p.logs.take(10).map((v) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.cardPadding, vertical: AppDimensions.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusMd), border: Border.all(color: AppColors.borderSubtle)),
          child: Row(children: [
            const Icon(Icons.favorite_rounded, color: AppColors.heartColor, size: 20),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (v.heartRate != null) Text('HR: ${v.heartRate} bpm', style: AppTextStyles.bodyMd),
              if (v.systolic != null) Text('BP: ${v.systolic}/${v.diastolic} mmHg', style: AppTextStyles.bodyMd),
            ])),
            Text(_formatDate(v.date), style: AppTextStyles.bodySmSecondary),
          ]),
        )),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _PulsingHeart extends StatefulWidget {
  const _PulsingHeart();
  @override State<_PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<_PulsingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _scale,
    builder: (_, __) => Transform.scale(scale: _scale.value, child: const Icon(Icons.favorite_rounded, color: AppColors.heartColor, size: 48)),
  );
}

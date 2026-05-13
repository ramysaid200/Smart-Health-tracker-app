import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../navigation/app_router.dart';

/// Medications screen – list and take medication
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MedicationProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addMedication).then((_) => context.read<MedicationProvider>().load()))],
      ),
      body: Consumer<MedicationProvider>(
        builder: (_, p, __) => p.isLoading
            ? const LoadingIndicator()
            : p.medications.isEmpty
                ? EmptyStateWidget(title: 'No medications', subtitle: 'Add your first medication to receive reminders', icon: Icons.medication_rounded, color: AppColors.error, actionLabel: 'Add Medication', onAction: () => Navigator.pushNamed(context, AppRouter.addMedication))
                : ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: p.medications.length,
                    itemBuilder: (_, i) => _MedCard(med: p.medications[i], onDelete: () => p.deleteMedication(p.medications[i].id)),
                  ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.med, required this.onDelete});
  final MedicationModel med; final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
          child: const Icon(Icons.medication_rounded, color: AppColors.error, size: AppDimensions.iconXl),
        ),
        const SizedBox(width: AppDimensions.base),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(med.name, style: AppTextStyles.h5),
          Text('${med.dosage} • ${med.frequency}', style: AppTextStyles.bodySmSecondary),
          if (med.times.isNotEmpty) Text(med.times.join(', '), style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
        ])),
        Column(children: [
          if (med.reminderEnabled) const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: AppDimensions.iconMd),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: AppDimensions.iconMd), onPressed: onDelete, constraints: const BoxConstraints(), padding: EdgeInsets.zero),
        ]),
      ]),
    );
  }
}

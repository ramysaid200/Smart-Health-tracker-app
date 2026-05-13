import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';

/// Add weight screen
class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});
  @override State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final _ctrl = TextEditingController();
  String _unit = 'kg';

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final weight = double.tryParse(_ctrl.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid weight'), backgroundColor: AppColors.error));
      return;
    }
    await context.read<WeightProvider>().addWeight(weight, _unit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged! ⚖️')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Weight'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(children: [
          const SizedBox(height: AppDimensions.xxxl),
          const Icon(Icons.monitor_weight_rounded, color: AppColors.weightColor, size: AppDimensions.iconHuge),
          const SizedBox(height: AppDimensions.xl),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.metricLg.copyWith(color: AppColors.weightColor),
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: '70.0', hintStyle: AppTextStyles.metricLg.copyWith(color: AppColors.textHint)),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'kg', label: Text('kg')),
                ButtonSegment(value: 'lbs', label: Text('lbs')),
              ],
              selected: {_unit},
              onSelectionChanged: (s) => setState(() => _unit = s.first),
            ),
          ]),
          const Spacer(),
          CustomButton(label: 'Log Weight', onPressed: _save, icon: Icons.save_rounded),
          const SizedBox(height: AppDimensions.xl),
        ]),
      ),
    );
  }
}

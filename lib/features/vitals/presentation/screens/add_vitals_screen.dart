import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/utils/validators.dart';

/// Add vitals screen – heart rate and blood pressure
class AddVitalsScreen extends StatefulWidget {
  const AddVitalsScreen({super.key});
  @override State<AddVitalsScreen> createState() => _AddVitalsScreenState();
}

class _AddVitalsScreenState extends State<AddVitalsScreen> {
  final _hrCtrl = TextEditingController();
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() { _hrCtrl.dispose(); _systolicCtrl.dispose(); _diastolicCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final hr = int.tryParse(_hrCtrl.text);
    final sys = int.tryParse(_systolicCtrl.text);
    final dia = int.tryParse(_diastolicCtrl.text);

    if (hr == null && sys == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter at least one vital'), backgroundColor: AppColors.error));
      return;
    }

    final vitals = VitalsLogModel(id: '', date: DateTime.now(), heartRate: hr, systolic: sys, diastolic: dia, notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text);
    await context.read<VitalsProvider>().addVitals(vitals);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vitals logged! ❤️')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vitals'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Heart Rate', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          TextField(
            controller: _hrCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMd,
            decoration: const InputDecoration(labelText: 'BPM (optional)', hintText: 'e.g. 72', prefixIcon: Icon(Icons.favorite_rounded, color: AppColors.heartColor)),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Blood Pressure', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          Row(children: [
            Expanded(child: TextField(controller: _systolicCtrl, keyboardType: TextInputType.number, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Systolic', hintText: 'e.g. 120'))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm), child: Text('/', style: TextStyle(fontSize: 24, color: AppColors.textSecondary))),
            Expanded(child: TextField(controller: _diastolicCtrl, keyboardType: TextInputType.number, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Diastolic', hintText: 'e.g. 80'))),
          ]),
          const SizedBox(height: AppDimensions.xl),
          TextField(controller: _notesCtrl, maxLines: 2, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'Any observations?', prefixIcon: Icon(Icons.notes_rounded))),
          const SizedBox(height: AppDimensions.xxxl),
          CustomButton(label: 'Save Vitals', onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }
}

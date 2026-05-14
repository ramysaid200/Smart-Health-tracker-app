import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../services/notification_service.dart';

/// Add medication screen
class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});
  @override State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  String _frequency = 'daily';
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  bool _reminder = true;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() { _nameCtrl.dispose(); _dosageCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _addTime() async {
    final picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (picked != null) setState(() => _times.add(picked));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _dosageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and dosage are required'), backgroundColor: AppColors.error));
      return;
    }

    final med = MedicationModel(
      id: '',
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim(),
      frequency: _frequency,
      times: _times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList(),
      startDate: DateTime.now(),
      reminderEnabled: _reminder,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text,
    );

    await context.read<MedicationProvider>().addMedication(med);

    // Schedule notifications if enabled
    if (_reminder) {
      for (int i = 0; i < _times.length; i++) {
        await NotificationService.instance.scheduleMedicationReminder(
          id: 200 + i,
          medicationName: med.name,
          dosage: med.dosage,
          time: _times[i],
        );
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medication added! 💊')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: _nameCtrl, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Medication Name', hintText: 'e.g. Vitamin D', prefixIcon: Icon(Icons.medication_rounded))),
          const SizedBox(height: AppDimensions.base),
          TextField(controller: _dosageCtrl, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Dosage', hintText: 'e.g. 500mg, 1 tablet', prefixIcon: Icon(Icons.scale_rounded))),
          const SizedBox(height: AppDimensions.xl),
          Text('Frequency', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          Wrap(
            spacing: AppDimensions.sm,
            children: ['daily', 'weekly', 'custom'].map((f) => ChoiceChip(
              label: Text(f.toUpperCase().substring(0, 1) + f.substring(1)),
              selected: _frequency == f,
              onSelected: (_) => setState(() => _frequency = f),
              selectedColor: AppColors.primaryGlow,
            )).toList(),
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(children: [
            Text('Reminder Times', style: AppTextStyles.h5),
            const Spacer(),
            TextButton.icon(icon: const Icon(Icons.add_circle_outline_rounded), label: const Text('Add'), onPressed: _addTime),
          ]),
          ..._times.asMap().entries.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded, color: AppColors.primary),
            title: Text(e.value.format(context), style: AppTextStyles.bodyMd),
            trailing: _times.length > 1 ? IconButton(icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error), onPressed: () => setState(() => _times.removeAt(e.key))) : null,
          )),
          const SizedBox(height: AppDimensions.base),
          Row(children: [
            Text('Enable Reminders', style: AppTextStyles.bodyMd),
            const Spacer(),
            Switch(value: _reminder, onChanged: (v) => setState(() => _reminder = v)),
          ]),
          const SizedBox(height: AppDimensions.base),
          TextField(controller: _notesCtrl, maxLines: 2, style: AppTextStyles.bodyMd, decoration: const InputDecoration(labelText: 'Notes (optional)', prefixIcon: Icon(Icons.notes_rounded))),
          const SizedBox(height: AppDimensions.xxxl),
          CustomButton(label: 'Add Medication', onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }
}

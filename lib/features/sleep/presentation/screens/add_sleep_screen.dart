import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../services/date_service.dart';

/// Add sleep log screen with time pickers and quality selector
class AddSleepScreen extends StatefulWidget {
  const AddSleepScreen({super.key});
  @override State<AddSleepScreen> createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends State<AddSleepScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  String _quality = 'good';
  final _notesCtrl = TextEditingController();

  static const _qualities = [
    {'key': 'poor', 'emoji': '😴', 'label': 'Poor'},
    {'key': 'fair', 'emoji': '😐', 'label': 'Fair'},
    {'key': 'good', 'emoji': '😊', 'label': 'Good'},
    {'key': 'excellent', 'emoji': '😁', 'label': 'Excellent'},
  ];

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  Future<void> _pickTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
    );
    if (picked != null) setState(() => isBedtime ? _bedtime = picked : _wakeTime = picked);
  }

  double get _durationHours {
    final bedDt = DateTime(2000, 1, 1, _bedtime.hour, _bedtime.minute);
    DateTime wakeDt = DateTime(2000, 1, 2, _wakeTime.hour, _wakeTime.minute);
    if (wakeDt.isBefore(bedDt)) wakeDt = wakeDt.add(const Duration(days: 1));
    return wakeDt.difference(bedDt).inMinutes / 60.0;
  }

  Future<void> _save() async {
    final today = DateService.instance.todayKey();
    final now = DateTime.now();
    final bedDt = DateTime(now.year, now.month, now.day, _bedtime.hour, _bedtime.minute).subtract(const Duration(days: 1));
    final wakeDt = DateTime(now.year, now.month, now.day, _wakeTime.hour, _wakeTime.minute);

    final log = SleepLogModel(date: today, bedtime: bedDt, wakeTime: wakeDt, quality: _quality, notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text);
    await context.read<SleepProvider>().addSleep(log);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sleep logged! 🌙')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Sleep'), leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _TimePicker(label: 'Bedtime', icon: Icons.bedtime_rounded, time: _bedtime, onTap: () => _pickTime(true))),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: _TimePicker(label: 'Wake Time', icon: Icons.wb_sunny_rounded, time: _wakeTime, onTap: () => _pickTime(false))),
          ]),
          const SizedBox(height: AppDimensions.xl),
          Container(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            decoration: BoxDecoration(color: AppColors.sleepColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppDimensions.cardRadius)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.timer_rounded, color: AppColors.sleepColor),
              const SizedBox(width: AppDimensions.sm),
              Text('Duration: ${_durationHours.toStringAsFixed(1)} hours', style: AppTextStyles.h5.copyWith(color: AppColors.sleepColor)),
            ]),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Sleep Quality', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          Row(children: _qualities.map((q) {
            final isSelected = _quality == q['key'];
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _quality = q['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sleepColor.withValues(alpha: 0.15) : AppColors.surface,
                  border: Border.all(color: isSelected ? AppColors.sleepColor : AppColors.borderSubtle, width: isSelected ? 1.5 : 1),
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: Column(children: [
                  Text(q['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(q['label']!, style: AppTextStyles.labelSm.copyWith(color: isSelected ? AppColors.sleepColor : AppColors.textSecondary)),
                ]),
              ),
            ));
          }).toList()),
          const SizedBox(height: AppDimensions.xl),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: AppTextStyles.bodyMd,
            decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'How did you sleep?', prefixIcon: Icon(Icons.notes_rounded)),
          ),
          const SizedBox(height: AppDimensions.xxxl),
          CustomButton(label: 'Log Sleep', onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({required this.label, required this.icon, required this.time, required this.onTap});
  final String label; final IconData icon; final TimeOfDay time; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(children: [
        Icon(icon, color: AppColors.sleepColor, size: AppDimensions.iconXl),
        const SizedBox(height: AppDimensions.sm),
        Text(label, style: AppTextStyles.bodySmSecondary),
        Text(time.format(context), style: AppTextStyles.metricSm.copyWith(color: AppColors.sleepColor)),
      ]),
    ),
  );
}

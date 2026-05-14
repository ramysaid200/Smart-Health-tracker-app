import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/utils/health_calculators.dart';
import '../../../../../services/storage_service.dart';

/// Add workout screen with type, duration, intensity
class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});
  @override State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  String _type = 'running';
  int _durationMinutes = 30;
  String _intensity = 'moderate';
  final _notesCtrl = TextEditingController();

  static const _types = [
    {'key': 'running', 'label': 'Running', 'emoji': '🏃'},
    {'key': 'walking', 'label': 'Walking', 'emoji': '🚶'},
    {'key': 'cycling', 'label': 'Cycling', 'emoji': '🚴'},
    {'key': 'swimming', 'label': 'Swimming', 'emoji': '🏊'},
    {'key': 'strength', 'label': 'Strength', 'emoji': '🏋️'},
    {'key': 'yoga', 'label': 'Yoga', 'emoji': '🧘'},
    {'key': 'hiit', 'label': 'HIIT', 'emoji': '⚡'},
  ];

  static const _intensities = ['low', 'moderate', 'high', 'intense'];

  double get _estimatedCalories {
    final weight = StorageService.instance.userWeight;
    return HealthCalculators.calculateWorkoutCalories(
      workoutType: _type,
      durationMinutes: _durationMinutes,
      weightKg: weight,
      intensity: _intensity,
    );
  }

  Future<void> _save() async {
    final workout = WorkoutModel(
      id: '',
      date: DateTime.now(),
      type: _type,
      durationMinutes: _durationMinutes,
      caloriesBurned: _estimatedCalories,
      intensity: _intensity,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await context.read<WorkoutProvider>().addWorkout(workout);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout logged! 💪')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() { _notesCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Workout Type', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppDimensions.sm,
            mainAxisSpacing: AppDimensions.sm,
            childAspectRatio: 0.9,
            children: _types.map((t) {
              final isSelected = _type == t['key'];
              return GestureDetector(
                onTap: () => setState(() => _type = t['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGlow : AppColors.surface,
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderSubtle, width: isSelected ? 1.5 : 1),
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(t['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(t['label']!, style: AppTextStyles.labelSm.copyWith(color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Duration: $_durationMinutes min', style: AppTextStyles.h5),
          Slider(
            value: _durationMinutes.toDouble(),
            min: 5, max: 180, divisions: 35,
            label: '$_durationMinutes min',
            onChanged: (v) => setState(() => _durationMinutes = v.round()),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text('Intensity', style: AppTextStyles.h5),
          const SizedBox(height: AppDimensions.sm),
          Row(children: _intensities.map((i) {
            final isSelected = _intensity == i;
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => setState(() => _intensity = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderSubtle),
                  ),
                  child: Text(i.toUpperCase().substring(0, 3), style: AppTextStyles.labelSm.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary), textAlign: TextAlign.center),
                ),
              ),
            ));
          }).toList()),
          const SizedBox(height: AppDimensions.xl),
          Container(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(AppDimensions.cardRadius)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.local_fire_department_rounded, color: AppColors.primary),
              const SizedBox(width: AppDimensions.sm),
              Text('Estimated: ${_estimatedCalories.toStringAsFixed(0)} kcal burned', style: AppTextStyles.h5.copyWith(color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: AppDimensions.xl),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: AppTextStyles.bodyMd,
            decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'How did it go?', prefixIcon: Icon(Icons.notes_rounded)),
          ),
          const SizedBox(height: AppDimensions.xxxl),
          CustomButton(label: 'Log Workout', onPressed: _save, icon: Icons.save_rounded),
        ]),
      ),
    );
  }
}

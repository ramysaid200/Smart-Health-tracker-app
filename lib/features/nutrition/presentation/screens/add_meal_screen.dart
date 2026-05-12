import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/utils/validators.dart';

/// Add meal / food item screen
class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});
  @override State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatsCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1 serving');
  String _mealType = 'breakfast';

  static const _mealTypes = ['breakfast', 'lunch', 'dinner', 'snacks'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _caloriesCtrl.dispose(); _proteinCtrl.dispose();
    _carbsCtrl.dispose(); _fatsCtrl.dispose(); _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = FoodItemModel(
      name: _nameCtrl.text.trim(),
      calories: double.tryParse(_caloriesCtrl.text) ?? 0,
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbsCtrl.text) ?? 0,
      fats: double.tryParse(_fatsCtrl.text) ?? 0,
      quantity: _quantityCtrl.text.trim(),
    );
    await context.read<NutritionProvider>().addFoodItem(item, _mealType);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meal logged! 🍽️')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Meal Type', style: AppTextStyles.labelLg),
            const SizedBox(height: AppDimensions.sm),
            Wrap(
              spacing: AppDimensions.sm,
              children: _mealTypes.map((t) => ChoiceChip(
                label: Text(t.capitalize),
                selected: _mealType == t,
                onSelected: (_) => setState(() => _mealType = t),
                selectedColor: AppColors.primaryGlow,
              )).toList(),
            ),
            const SizedBox(height: AppDimensions.xl),
            CustomTextField(
              controller: _nameCtrl,
              label: 'Food Name',
              hint: 'e.g. Chicken breast',
              prefixIcon: Icons.restaurant_rounded,
              validator: (v) => Validators.requiredField(v, 'Food name'),
            ),
            const SizedBox(height: AppDimensions.base),
            CustomTextField(
              controller: _quantityCtrl,
              label: 'Quantity',
              hint: 'e.g. 100g, 1 cup',
              prefixIcon: Icons.scale_rounded,
            ),
            const SizedBox(height: AppDimensions.xl),
            Text('Nutrition Info', style: AppTextStyles.h5),
            const SizedBox(height: AppDimensions.sm),
            CustomTextField(
              controller: _caloriesCtrl,
              label: 'Calories (kcal)',
              hint: 'e.g. 250',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.local_fire_department_rounded,
              validator: Validators.foodCalories,
            ),
            const SizedBox(height: AppDimensions.base),
            Row(children: [
              Expanded(child: _MacroField(ctrl: _proteinCtrl, label: 'Protein (g)', color: AppColors.proteinColor)),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: _MacroField(ctrl: _carbsCtrl, label: 'Carbs (g)', color: AppColors.carbsColor)),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: _MacroField(ctrl: _fatsCtrl, label: 'Fats (g)', color: AppColors.fatsColor)),
            ]),
            const SizedBox(height: AppDimensions.xxxl),
            CustomButton(label: 'Log Food', onPressed: _save, icon: Icons.save_rounded),
          ]),
        ),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({required this.ctrl, required this.label, required this.color});
  final TextEditingController ctrl; final String label; final Color color;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
    const SizedBox(height: AppDimensions.xs),
    TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(hintText: '0'),
    ),
  ]);
}

extension on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}

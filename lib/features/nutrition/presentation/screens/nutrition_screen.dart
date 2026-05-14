import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/models/health_models.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/widgets/section_header.dart';
import '../../../../../core/providers/health_providers.dart';
import '../../../../../navigation/bottom_nav_bar.dart';
import '../../../../../navigation/app_router.dart';

/// Nutrition tracking screen with meal breakdown and macro chart
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<NutritionProvider>().loadToday());
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 1,
      body: Consumer<NutritionProvider>(
        builder: (_, p, __) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Nutrition'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => Navigator.pushNamed(context, AppRouter.addMeal).then((_) => p.loadToday())),
            ],
          ),
          body: p.isLoading
              ? const LoadingIndicator()
              : RefreshIndicator(
                  color: AppColors.nutritionColor,
                  onRefresh: p.loadToday,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    child: Column(children: [
                      if (p.today != null) ...[
                        FadeInDown(child: _buildCalorieHeader(p)),
                        const SizedBox(height: AppDimensions.xl),
                        FadeInUp(delay: const Duration(milliseconds: 100), child: _buildMacroChart(p)),
                        const SizedBox(height: AppDimensions.xl),
                      ],
                      FadeInUp(delay: const Duration(milliseconds: 200), child: _buildMeals(context, p)),
                      const SizedBox(height: AppDimensions.massive),
                    ]),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCalorieHeader(NutritionProvider p) {
    final cal = p.today!.totalCalories;
    final goal = p.calorieGoal;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Calories', style: AppTextStyles.h5),
          Text('${cal.toStringAsFixed(0)} / $goal kcal', style: AppTextStyles.metricSm.copyWith(color: AppColors.nutritionColor)),
        ]),
        const SizedBox(height: AppDimensions.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: LinearProgressIndicator(
            value: (cal / goal).clamp(0, 1),
            backgroundColor: AppColors.nutritionColor.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation(AppColors.nutritionColor),
            minHeight: 10,
          ),
        ),
      ]),
    );
  }

  Widget _buildMacroChart(NutritionProvider p) {
    final today = p.today!;
    final protein = today.totalProtein;
    final carbs = today.totalCarbs;
    final fats = today.totalFats;
    final total = protein + carbs + fats;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Macro Breakdown', style: AppTextStyles.h5),
        const SizedBox(height: AppDimensions.base),
        Row(children: [
          SizedBox(
            width: 100, height: 100,
            child: PieChart(PieChartData(
              sections: total > 0 ? [
                PieChartSectionData(value: carbs, color: AppColors.carbsColor, title: '', radius: 20),
                PieChartSectionData(value: protein, color: AppColors.proteinColor, title: '', radius: 20),
                PieChartSectionData(value: fats, color: AppColors.fatsColor, title: '', radius: 20),
              ] : [PieChartSectionData(value: 1, color: AppColors.borderSubtle, title: '', radius: 20)],
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ), duration: const Duration(milliseconds: 800)),
          ),
          const SizedBox(width: AppDimensions.xl),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _MacroRow('Carbs', carbs, total, AppColors.carbsColor),
            const SizedBox(height: AppDimensions.sm),
            _MacroRow('Protein', protein, total, AppColors.proteinColor),
            const SizedBox(height: AppDimensions.sm),
            _MacroRow('Fats', fats, total, AppColors.fatsColor),
          ])),
        ]),
      ]),
    );
  }

  Widget _buildMeals(BuildContext context, NutritionProvider p) {
    final today = p.today;
    final meals = [
      {'name': 'Breakfast', 'icon': '☀️', 'items': today?.breakfast ?? []},
      {'name': 'Lunch', 'icon': '🥗', 'items': today?.lunch ?? []},
      {'name': 'Dinner', 'icon': '🍽️', 'items': today?.dinner ?? []},
      {'name': 'Snacks', 'icon': '🍎', 'items': today?.snacks ?? []},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Meals', actionLabel: 'Add', onAction: () => Navigator.pushNamed(context, AppRouter.addMeal).then((_) => p.loadToday())),
        const SizedBox(height: AppDimensions.sm),
        ...meals.map((m) => _MealCard(
          name: m['name'] as String,
          icon: m['icon'] as String,
          items: m['items'] as List<FoodItemModel>,
          onAdd: () => Navigator.pushNamed(context, AppRouter.addMeal).then((_) => p.loadToday()),
        )),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow(this.label, this.value, this.total, this.color);
  final String label; final double value; final double total; final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: AppDimensions.xs),
      Expanded(child: Text(label, style: AppTextStyles.bodySmSecondary)),
      Text('${value.toStringAsFixed(1)}g • $pct%', style: AppTextStyles.labelSm),
    ]);
  }
}

class _MealCard extends StatefulWidget {
  const _MealCard({required this.name, required this.icon, required this.items, required this.onAdd});
  final String name; final String icon; final List<FoodItemModel> items; final VoidCallback onAdd;
  @override State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  bool _expanded = false;
  double get _totalCal => widget.items.fold(0, (sum, i) => sum + i.calories);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(AppDimensions.cardRadius), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(children: [
        ListTile(
          leading: Text(widget.icon, style: const TextStyle(fontSize: 24)),
          title: Text(widget.name, style: AppTextStyles.h5),
          subtitle: Text('${_totalCal.toStringAsFixed(0)} kcal', style: AppTextStyles.bodySmSecondary),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary), onPressed: widget.onAdd),
            Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          ]),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded && widget.items.isEmpty)
          Padding(padding: const EdgeInsets.all(AppDimensions.base), child: Text('No items added', style: AppTextStyles.bodySmSecondary)),
        if (_expanded)
          ...widget.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.cardPadding, vertical: 6),
            child: Row(children: [
              Expanded(child: Text(item.name, style: AppTextStyles.bodyMd)),
              Text('${item.calories.toStringAsFixed(0)} kcal', style: AppTextStyles.labelMd),
            ]),
          )),
        if (_expanded) const SizedBox(height: AppDimensions.sm),
      ]),
    );
  }
}
